import token_registry.aleo;

// Test Token Program
// Based on Aleo samples - uses Aleo Token Registry
program bean_token.aleo {
  const BEAN_TOKEN_ID: field = 1986245370112742436875568105128650176313749927841508924213988105972156054969field;

  async transition initialize() -> Future {
    let name: u128 = 438210606665080095251217407394791758u128; // "Test token BEAN" ascii encoded
    let symbol: u128 = 1111834958u128; // "BEAN" ascii encoded
    let decimals: u8 = 6u8;
    let max_supply: u128 = 10_000_000_000_000_000u128;
    let external_authorization_required: bool = false;
    let external_authorization_party: address = self.address;

    let f: Future = token_registry.aleo/register_token(
      BEAN_TOKEN_ID,
      name,
      symbol,
      decimals,
      max_supply,
      external_authorization_required,
      external_authorization_party
      );

    return finalize_initialize(f);
  }
  async function finalize_initialize(f: Future) {
    f.await();
  }

  async transition mint_public(
    public recipient: address,
    public amount: u128,
  ) -> Future{
    let f: Future = token_registry.aleo/mint_public(BEAN_TOKEN_ID, recipient, amount, 0u32);
    return finalize_mint_public(f);
  }
  async function finalize_mint_public(f: Future) {
    f.await();

  }
}