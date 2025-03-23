import token_registry.aleo;

program trust.aleo {

  mapping wrapped_id_to_unwrapped_id: field => field;

  record TrusteeConsent {
    owner: address, // Trustee initially, handed over to Beneficiary as consent
    beneficiary: address,
    will_id: field
  }

  record Will {
    owner: address, // The Beneficiary
    grantor: address, // The Grantor
    beneficiary: address, // The Beneficiary
    will_id: field,
    funding_token_id: field,
    funding_amount: u128,
    approvals_needed: u8,
    approvals_received: u8,
    good_after: u32,
  }

  transition balance_key(private account: address, private token_id: field) -> private field {
    let owner: TokenOwner = TokenOwner {
      account: account,
      token_id: token_id
    };
    return BHP256::hash_to_field(owner);
  }

  inline wrapped_id(token_id: field) -> field {
    return BHP256::hash_to_field(token_id);
  }

  transition get_wrapped_id(private token_id: field) -> private field {
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

  transition generate_dead_address(private nonce: u64) -> private address {
    return dead_address(nonce);
  }

  // This provides plausible deniability. If transferring to a dead address, the transfer is not public-to-private.
  // Otherwise, if the nonce is 0, the address is not considered dead (unless the sender makes a mistake equivalent to sending), 
  // to a random address) the transfer is public-to-public.
  async transition transfer(public wrapper_token_id: field, public amount: u128, private destination: address, private nonce: u64) -> (private token_registry.aleo/Token, Future) {
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

  async transition unwrap_private(private private_wrapper_token: token_registry.aleo/Token, private token_id: field, private amount: u128) -> (private token_registry.aleo/Token, private token_registry.aleo/Token, Future) {
    let (private_token, ftp): (token_registry.aleo/Token, Future) = token_registry.aleo/transfer_public_to_private(token_id, self.caller, amount, false); // there is always enough, as it was previously wrapped
    let (change_wrapper_token, fb): (token_registry.aleo/Token, Future) = token_registry.aleo/burn_private(private_wrapper_token, amount);
    return (private_token, change_wrapper_token, finalize_unwrap_private(ftp, fb));
  }
  async function finalize_unwrap_private(ftp: Future, fb: Future) {
    ftp.await(); // transfer public from this contract to private (to caller)
    fb.await(); // burn wrapper token as caller
  }

  // Set up trust - performed by grantor
  // Given to beneficiary after adding trustees
  transition trust_setup(
    private funding: token_registry.aleo/Token, 
    private beneficiary: address, 
    private will_id: field, // Make sure this is generated in a way that is unique
    private nonce: u64,
    private approvals_needed: u8,
    private good_after: u32) -> private Will 
  {
    return Will {
      owner: self.caller,
      grantor: self.caller,
      beneficiary: beneficiary,
      will_id: will_id,
      funding_token_id: funding.token_id,
      funding_amount: funding.amount,
      approvals_needed: approvals_needed,
      approvals_received: 0u8,
      good_after: good_after
    };
  }

  // Grantor approves Trustee and passes the nonce to Trustee
  transition add_trustee(private will: Will, private trustee: address) -> (Will, TrusteeConsent) {
    let same_will: Will = Will {
      owner: will.owner,
      grantor: will.grantor,
      beneficiary: will.beneficiary,
      will_id: will.will_id,
      funding_token_id: will.funding_token_id,
      funding_amount: will.funding_amount,
      approvals_needed: will.approvals_needed,
      approvals_received: will.approvals_received,
      good_after: will.good_after
    };
    let voucher: TrusteeConsent = TrusteeConsent {
      owner: trustee,
      beneficiary: will.beneficiary,
      will_id: will.will_id
    };
    return (same_will, voucher);
  }

  // Trustee consents to the will execution - sends the consent to the beneficiary
  transition trustee_consents(private voucher: TrusteeConsent) -> private TrusteeConsent {
    return TrusteeConsent {
      owner: voucher.beneficiary,
      beneficiary: voucher.beneficiary,
      will_id: voucher.will_id
    };
  }

  // Beneficiary counts and registers the consent
  transition register_approval(private will: Will, private trustee_consent: TrusteeConsent) -> Will {
    assert(will.will_id == trustee_consent.will_id);
    return Will {
      owner: will.owner,
      grantor: will.grantor,
      beneficiary: will.beneficiary,
      will_id: will.will_id,
      funding_token_id: will.funding_token_id,
      funding_amount: will.funding_amount,
      approvals_needed: will.approvals_needed,
      approvals_received: will.approvals_received + 1u8,
      good_after: will.good_after
    };
  }

  // Beneficiary cashes out
  async transition cash_out(private will: Will, private decoy_time: u32) -> (token_registry.aleo/Token, Future) {
    assert(will.good_after <= decoy_time);// We can pass the number of approvals counted
    assert(will.approvals_received >= will.approvals_needed);
    let (token, fpm): (token_registry.aleo/Token, Future) = token_registry.aleo/mint_private(will.funding_token_id, self.caller, will.funding_amount, false, 0u32);
    let f: Future = finalize_cash_out(fpm, decoy_time);
    return (token, f);
  }
  async function finalize_cash_out(fpm: Future, decoy_time: u32) {
    fpm.await();
    assert(decoy_time < block.height);
  }
}
