# truZt arKanum (Trust Arcanum) - Secretly Programmable Money

The demo instructions and video can be found [here](./demo/README.md).

## Abstract

truZt arKanum is a Secretly Programmable money protocol. It allows for private fund transfers with plausible deniability,
executable at a pre-determined time in the future, controlled by multiple signers and pre-programmed on-chain conditions.
It also allows the participants to reveal their transactions if they want to, in order to cater to defense against accusations of wrongdoing or breach of agreement.

## Introduction

Generally blockchains protect against data corruptibility via consensus. This naturally entails visibility of all data. Yet,
data privacy is important, especially when it involves finances. Needless to discuss the reason for banking secrecy.

Notable pioneering project in on-chain fund transfer privacy is Tornado.cash. It has allowed shielding of the source and destination
of fund transfers. This is a good start, however a lot more functionality is needed:
- Plausible deniability: It is not enough to shield the connection between the sender and the recipient of the funds. They need to be
protected from prying eyes that they participated in such transfers at all.
- Timing: Future private transactions need protection as well. This is important for inheritance processing.
- Multiple signers: Private transactions that need approval of multiple participants. This is important in will executor cases, corporate financial
controls and many other cases.
- Conditions: Private transactions that need satisfaction of certain future on-chain conditions before execution. This is important in grant disbursement, investment management and other cases.
- Revealing: If accused of wrongdoing, the participants in such private transactions should be able to selectively reveal their actions in order to defend themselves by giving read-only access to the authorities or other accusers
of unethical behavior.

The truZt arKanum protocol provides a solution to the above issues in a simple manner using combination of Zero Knowledge and Consensus mechanisms.

## Implementation

We have chosen the ***Aleo*** blockchain for the implementation of the truZt arKanum Protocol. The reasons for this
are the following features of Aleo:
- Zero Knowledge proving system that allows off-chain execution and proof of correctness of such actions.
- Encrypted records that allow transfer of private information between participants.
- Built-in nullifier handling which avoids unnecessary duplicate code.
- Consensus which allows for participation of multiple parties.
- Programmability which allows expressing execution conditions of the financial transactions.
- View Keys which allow for read-only revelation of transactions, to to clear honest participants' names. 

### Secret transfers with plausible deniability

### Time

### Multisig

### General conditions

### Verification

Nothing needs to be done here. Aleo allows for creation of View Keys from any private key. Revealing the view
key allows the recipient to discover and read the transactions that have used the corresponding private key.

Each participant has to agree to disclose their actions and reveal their Vew Keys.

Using different private keys (accounts) can help users isolate their unrelated actions against being cross-referenced.

## Future work
