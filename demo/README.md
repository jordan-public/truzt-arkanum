# Demo and Video

## Video

The video can be found [here]() and on [YouTube](https:://).

## How to install and run

Clone this repository.

Find all `.env.example` files in all folders, copy them to `.env` in the same folder and edit them accordingly.

Install the JavaScript dependencies:
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

To install on a local Aleo development node first run the following script in a MacOS (or Linux) terminal:
```zsh
./run_node.sh
```
and leave this process running.

To install the programs in another terminal run:
```zsh
./install.sh
```

## Demo of public-to-private transfer with plausible deniability

Let's see the address that corresponds to our private key defined in `.env` as `PRIVATE_KEY`. From the root folder of the project:
```zsh
cd cli
./showkey.js
```

We see that our address is `aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px`.

Let's mint 1000 BEAN tokens. These are test tokens that we can mint at will:
```zsh
cd ../bean_token aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px 1000u128
```

Let's approve the `trust.aleo` program (the zruZt arKanum program) to spend 100 of our beans:
```zsh
cd ../token_registry_workaround
./approve_BEAN.sh trust.aleo 100u128
```

Now, we can wrap 50 BEAN tokens publically:
```zsh
cd ../trust
./wrap_public_BEAN.sh 50u128
```

We can get the Wrapped BEAN token id:
```zsh
cd ../trust
./get_wrapped_BEAN_id.sh
```
and get `4272297468386804690725057900432538860186578348390042053805776907130316959492field`.

Now let's generate a random private key and address:
```zsh
cd ../cli
./genkey.js
```
We got address `aleo1a5pc3cywe287e9jnj3al6rd0cqvnrjhj2kdc9a74pg7ua0855qxsss3ycq`, but you will get another 
one when running this.

Let's authorize the program `trust.aleo` to move 10 Wrapped BEAN tokens from our account:
```zsh
cd cd ../token_registry_workaround
./approve.sh 4272297468386804690725057900432538860186578348390042053805776907130316959492field trust.aleo 10u128
```

Now let's transfer 10 Wrapped BEAN tokens to this address:
```zsh
cd ../trust
./transfer.sh 4272297468386804690725057900432538860186578348390042053805776907130316959492field 10u128 aleo1a5pc3cywe287e9jnj3al6rd0cqvnrjhj2kdc9a74pg7ua0855qxsss3ycq 0u64
```
Note that the last parameter, <nonce> is 0u64. This means that we are asking for a regular transfer, but no one else knows this.
The Wrapped BEAN tokens went to the destination address, and we received a record with no private tokens 
(a decoy):
```
{
  owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px.private,
  amount: 0u128.private,
  token_id: 4272297468386804690725057900432538860186578348390042053805776907130316959492field.private,
  external_authorization_required: false.private,
  authorized_until: 0u32.private,
  _nonce: 6840818669296653373262964563821917379888234304067837850921204144382127340834group.public
}
```

Now ***this is important!*** Let's generate a dead address using the nonce 1234u64. This number is not important - it could be random or not,
but if we repeat this process with the same nonce, we will get the same dead address again. This way we can even pretend to send tokens multiple times to this address, but receive the private tokens elsewhere:
```zsh
cd ../trust
./generate_dead_address.sh 1234u64
```
We get `aleo1eqcc9tftswya8mnhht6rkwmryxneyxe8m96wg4fe93p6t2gr9g9qtcdm8f`.

Let's authorize the program `trust.aleo` to move 10 Wrapped BEAN tokens from our account again:
```zsh
cd cd ../token_registry_workaround
./approve.sh 4272297468386804690725057900432538860186578348390042053805776907130316959492field trust.aleo 10u128
```

Finally, ***here is the public-to-private transfer with plausible deniability***. Let's send 10 Wrapped BEAN tokens:
```zsh
cd ../trust
./transfer.sh 4272297468386804690725057900432538860186578348390042053805776907130316959492field 10u128 aleo1eqcc9tftswya8mnhht6rkwmryxneyxe8m96wg4fe93p6t2gr9g9qtcdm8f 1234u64
```
Now let's observe the private Aleo Record that we received. It contains 10 private Wrapped BEAN tokens:
```
{
  owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px.private,
  amount: 10u128.private,
  token_id: 4272297468386804690725057900432538860186578348390042053805776907130316959492field.private,
  external_authorization_required: false.private,
  authorized_until: 0u32.private,
  _nonce: 4376738812965965071846568354306828232263054938358375135859497712818188067299group.public
}
```
and no one except us knows about this. For everyone else, it looks like we transferred the Wrapped BEAN
tokens publicly to our dead address `aleo1eqcc9tftswya8mnhht6rkwmryxneyxe8m96wg4fe93p6t2gr9g9qtcdm8f` and
no one can find out that this is a dead address. But we should pick some large random u64 number for the nonce,
that no one can guess, to keep this secret. 

Let's see what everyone else sees:
```zsh
cd ../cli
./bal.js aleo1eqcc9tftswya8mnhht6rkwmryxneyxe8m96wg4fe93p6t2gr9g9qtcdm8f 4272297468386804690725057900432538860186578348390042053805776907130316959492field
```
They see `Balance: 10u128` at the address `aleo1eqcc9tftswya8mnhht6rkwmryxneyxe8m96wg4fe93p6t2gr9g9qtcdm8f`. Only we know that this address is dead and no one can used these "fake" funds.


## Demo of private transfers under condition of future execution upon 2 of 3 signers

Here is the scenario that we will demonstrate:
- There is inheritance at one address.
- The inheritance cannot be disbursed before a specific time, to prevent minors from frivolous spending.
- The inheritance need to be approved by two of the three trustees to trigger execution of the Will.
- When all above is satisfied, the beneficiary can trigger the transfer.

And here are the secrecy requirements:
- No one outside the involved parties shall be able to find out that there is inheritance in question at all, let alone the amount
of funds involved.
- Trustees cannot know about each other, nor how many trustees there are, who they are, and how many approvals are needed. This way they cannot collude.
- Only the beneficiary can find out which trustees signed the approval of transfer.
- No one can, not even the trustees can find out the amount of
inheritance.
- No one can find out whether or when the beneficiary is spending
the inheritance.
- No one can find out the time before which the inheritance cannot
be disbursed.

Let's set this up:
TBD