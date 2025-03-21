import token_registry.aleo;

program trust.aleo {

  mapping wrapped_id_to_unwrapped_id: field => field;

  transition balance_key(account: address, token_id: field) -> field {
    let owner: TokenOwner = TokenOwner {
      account: account,
      token_id: token_id
    };
    return BHP256::hash_to_field(owner);
  }

  inline wrapped_id(token_id: field) -> field {
    return BHP256::hash_to_field(token_id);
  }

  transition get_wrapped_id(token_id: field) -> field {
    return wrapped_id(token_id);
  }

  async transition create_wrapper(public token_id: field) -> Future {
    let name: u128 = 6928249226643524685988262274414u128; // "Wrapper token" ascii encoded
    let symbol: u128 = 5722708u128; // "WRT" ascii encoded
    let decimals: u8 = 6u8;
    let max_supply: u128 = 10_000_000_000_000_000u128;
    let external_authorization_required: bool = false;
    let external_authorization_party: address = self.address;

    let wrapper_token_id: field = wrapped_id(token_id); // deterministic conversion

    let f: Future = token_registry.aleo/register_token(
      wrapper_token_id,
      name,
      symbol,
      decimals,
      max_supply,
      external_authorization_required,
      external_authorization_party
    );

    return finalize_create_wrapper(wrapper_token_id, token_id, f);
  }
  async function finalize_create_wrapper(wrapper_token_id: field, token_id: field, f: Future) {
    Mapping::set(wrapped_id_to_unwrapped_id, wrapper_token_id, token_id);
    f.await();
  }

  async transition wrap_public(public token_id: field, public amount: u128) -> Future {
    let wrapper_token_id: field = wrapped_id(token_id);
    let fm: Future = token_registry.aleo/mint_public(wrapper_token_id, self.caller, amount, 0u32);
    let ft: Future = token_registry.aleo/transfer_from_public(token_id, self.caller, self.address, amount);
    return finalize_wrap_public(fm, ft);
  }
  async function finalize_wrap_public(fm: Future, ft: Future) {
    fm.await(); // mint wrapper token
    ft.await(); // transfer balance to contract
  }

  async transition unwrap_public(public wrapper_token_id: field, public token_id: field, public amount: u128) -> Future {
    let fb: Future = token_registry.aleo/burn_public(wrapper_token_id, self.caller, amount);
    let ft: Future = token_registry.aleo/transfer_public(token_id, self.caller, amount);
    return finalize_unwrap_public(wrapper_token_id, token_id, fb, ft);
  }
  async function finalize_unwrap_public(wrapper_token_id: field, token_id: field, fb: Future, ft: Future) {
    assert_eq(token_id, wrapped_id_to_unwrapped_id.get(wrapper_token_id));
    fb.await(); // transfer wrapper token
    ft.await(); // mint unwrapped token
  }

  // Generate a dead address from a nonce, similar to the EIP-7503 ZK Wormhole (https://eip7503.org/), but better:
  // there is no need to make a change to the EVM. Each nonce generates a unique dead address.
  function dead_address(nonce: u64) -> address {
        return Pedersen128::hash_to_address(nonce);
  }

  // This provides plausible deniability. If transferring to a dead address, the transfer is not public-to-private.
  // Otherwise, if the nonce is 0, the address is not considered dead (unless the sender makes a mistake equivalent to sending), 
  // to a random address) the transfer is public-to-public.
  async transition transfer(public wrapper_token_id: field, public amount: u128, private destination: address, private nonce: u64) -> (token_registry.aleo/Token, Future) {
    let ft: Future = token_registry.aleo/transfer_from_public(wrapper_token_id, self.caller, destination, amount);
    let private_amount: u128 = 0u128;
    if (destination == dead_address(nonce)) { private_amount = amount; } // Plausible deniability of private mint
    let (token, fpm): (token_registry.aleo/Token, Future) = token_registry.aleo/mint_private(wrapper_token_id, self.caller, private_amount, false, 0u32);
    return (token, finalize_transfer(ft, fpm));
  }
  async function finalize_transfer(ft: Future, fpm: Future) {
    ft.await(); // transfer wrapper token
    fpm.await(); // mint private token
  }

  async transition unwrap_private(private private_wrapper_token: token_registry.aleo/Token, private token_id: field, private amount: u128) -> (token_registry.aleo/Token, token_registry.aleo/Token, Future) {
    let (private_token, ftp): (token_registry.aleo/Token, Future) = token_registry.aleo/transfer_public_to_private(token_id, self.caller, amount, false); // there is always enough, as it was previously wrapped
    let (change_wrapper_token, fb): (token_registry.aleo/Token, Future) = token_registry.aleo/burn_private(private_wrapper_token, amount);
    return (private_token, change_wrapper_token, finalize_unwrap_private(ftp, fb));
  }
  async function finalize_unwrap_private(ftp: Future, fb: Future) {
    ftp.await(); // transfer public from this contract to private (to caller)
    fb.await(); // burn wrapper token as caller
  }
}
