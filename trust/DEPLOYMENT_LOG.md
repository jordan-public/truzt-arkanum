# Program deployment log

The Aleo program `trust.aleo` was renamed to `trust_trust_trust.aleo` in order to save on naming fee expenses.

This change can be seen in the branch `testnet-deployment` of this repository.

Here is the deployment log:
```
jordan@p21 trust % ./deploy_testnet.sh
+./deploy_testnet.sh:5> . ./.env
+./.env:1> NETWORK=testnet 
+./.env:2> PRIVATE_KEY=APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH 
+./.env:3> ENDPOINT=http://localhost:3030 
+./.env:5> TESTNET_PRIVATE_KEY=APrivateKey1zkp8i1nnKBrnxsrFQNir7TYpmCsYLRMder5vr3vUBXRAq8G 
+./.env:6> TESTNET_ENDPOINT=https://api.explorer.provable.com/v1 
+./deploy_testnet.sh:7> leo deploy --path . --network testnet --private-key APrivateKey1zkp8i1nnKBrnxsrFQNir7TYpmCsYLRMder5vr3vUBXRAq8G --endpoint https://api.explorer.provable.com/v1 --yes --recursive
       Leo ✅ Compiled 'trust_trust_trust.aleo' into Aleo instructions
📦 Creating deployment transaction for 'trust_trust_trust.aleo'...

📊 Deployment Summary:
      Total Variables:      662,660
      Total Constraints:    503,171

Base deployment cost for 'trust_trust_trust.aleo' is 43.638775 credits.

+------------------------+----------------+
| trust_trust_trust.aleo | Cost (credits) |
+------------------------+----------------+
| Transaction Storage    | 13.493000      |
+------------------------+----------------+
| Program Synthesis      | 29.145775      |
+------------------------+----------------+
| Namespace              | 1.000000       |
+------------------------+----------------+
| Priority Fee           | 0.000000       |
+------------------------+----------------+
| Total                  | 43.638775      |
+------------------------+----------------+

Your current public balance is 210 credits.

✅ Created deployment transaction for 'trust_trust_trust.aleo'

Broadcasting transaction to https://api.explorer.provable.com/v1/testnet/transaction/broadcast...

⌛ Deployment at1jznj9pynqg8jak2mvewu02tnpp898r73sd6htge2hcd74g0puurqskkw9d ('trust_trust_trust.aleo') has been broadcast to https://api.explorer.provable.com/v1/testnet/transaction/broadcast.
```