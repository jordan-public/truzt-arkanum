# Command Line Interface (CLI)

Recommend Node.js 20+ for best performance.

To install, run:
```zsh
pnpm install
pnpm approve-builds
```
And approve everything when asked.

To run:
```zsh
./<command>.js
```
If it does not run, the file is not meant to run standalone.

Her is the list of all commands, some written as ZSH scripts and some in JavaScript running in Node.js. The usage parameters can
be discovered by running the command without parameters:

- /cli/bal.js: shows the balance of the given token by ID at the given address.
- /cli/showkey.js: shows the Verification Key and the Address of the account specified by the Private Key listed in the local `.env` file under PRIVATE_KEY.
- /cli/genkey.js: generates a random Private Key and shows it and its associated Verifcation Key and Address.
- /cli/mintBEAN.js: mints a desired amount of test BEAN tokens into the given Address.
- /token_registry_workaround/approve.sh: approves spending by a given address (user or contract) of a given amount of the token specified by ID.
- /token_registry_workaround/approve_BEAN.sh: approves spending by a given address (user or contract) of a given amount of the test BEAN token.
- /bean_token/mint_BEAN.sh: mints a given amount of test BEAN tokens into the given Address.
- /trust/generate_dead_address.sh: generates a Dead Address from a given Nonce.
- /trust/get_wrapped_token_id.sh: displays the truZt arKanum Protocol wrapper token ID for a given token by ID.
- /trust/transfer.sh: performs a plausibly deniable transfer of the public-to-private and/or public-to-public kind. 
- /trust/wrap_public_BEAN.sh: wraps BEAN test tokens publicly.
- /trust/get_wrapped_BEAN_id.sh: gets the ID of the Wrapped BEAN test token.
- /trust/wrap_public.sh: wraps tokens by given ID publicly.