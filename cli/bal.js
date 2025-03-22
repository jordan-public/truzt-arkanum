#!/usr/bin/env node

import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';
import dotenv from 'dotenv';
import { Account, AleoNetworkClient, Program, BHP256 } from '@provablehq/sdk';
import { type } from 'os';
import { queryBalanceKey } from './queryBalanceKey.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: resolve(__dirname, '.env') });

// Get command line arguments
const address = process.argv[2];

if (!address) {
    console.error('Usage: node bal.js <address> <token_id>');
    process.exit(1);
}

async function checkBalance() {
    try {
        // Initialize network client
        console.log('Endpoint:', process.env.ENDPOINT);
        const networkClient = new AleoNetworkClient(process.env.ENDPOINT);
        const account = new Account({ privateKey: process.env.PRIVATE_KEY });
        networkClient.setAccount(account);
        
        // Get the token ID from command line or environment
        const tokenId = process.argv[3] || process.env.TOKEN_ID;
        if (!tokenId) {
            throw new Error('Token ID must be provided as argument or in .env file');
        }
        
        // Construct the TokenOwner struct and compute its hash
        const program = new Program();
        const BHP256Hasher = new BHP256();
        const balanceKey = await queryBalanceKey(address, tokenId);
// console.log('Address:', address, typeof address);
// console.log('Token ID:', tokenId, typeof tokenId);
//         const balanceKey = BHP256Hasher.hash({
//             account: address,
//             token_id: tokenId
//         }.toString());
        //const balanceKey = "6845706601203830423999732856578850002275288369334368166945372691607344762173field";
//console.log('Balance Key:', balanceKey.toString());
        
        // Query the program state using the hashed key
        const b = await networkClient.getProgramMappingValue(
            "token_registry.aleo",
            "authorized_balances",
            balanceKey
        );
        let balance = '0u128';
        if (b) {
            const validJson = b
                // Quote keys: replace any key (word) followed by : with the key quoted.
                .replace(/([{,]\s*)(\w+)\s*:/g, '$1"$2":')
                // Quote unquoted alphanumeric values that aren’t numbers or booleans (this is a simple heuristic)
                .replace(/:\s*([^",\s}{]+)([,\s}])/g, ': "$1"$2');
            const bStruct = JSON.parse(validJson);
            balance = bStruct.balance;
        }
        console.log('Balance:', balance);
        
    } catch (error) {
        console.error('Error checking balance:', error.message);
        console.log('Error details:', error);
        process.exit(1);
    }
}

checkBalance();
