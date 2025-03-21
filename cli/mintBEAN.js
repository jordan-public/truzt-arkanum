#!/usr/bin/env node

import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';
import dotenv from 'dotenv';
import { Account, AleoNetworkClient, AleoKeyProvider, NetworkRecordProvider, ProgramManager } from '@provablehq/sdk';
import { file_to_string } from './rw.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: resolve(__dirname, '.env') });

// Get command line arguments
const address = process.argv[2];
const amount = process.argv[3];

if (!address || !amount) {
    console.error('Usage: node mintBEAN.js <recipient_address> <amount>');
    process.exit(1);
}

// Validate amount is a positive integer
// if (!Number.isInteger(Number(amount)) || Number(amount) <= 0) {
//     console.error('Error: Amount must be a positive integer');
//     process.exit(1);
// }

async function mintTokens() {
    try {
        // Initialize Aleo account from private key
        const account = new Account({ privateKey: process.env.PRIVATE_KEY });
        console.log('From address:', account.address().to_string());
        
        // Initialize network client and program manager
        const networkClient = new AleoNetworkClient(process.env.ENDPOINT);
        const keyProvider = new AleoKeyProvider();
        keyProvider.useCache = true;
        const recordProvider = new NetworkRecordProvider(account, networkClient);
        const programManager = new ProgramManager(process.env.ENDPOINT, keyProvider, recordProvider);
        programManager.setAccount(account);

        // Read the program and its imports
        //const program = file_to_string('../bean_token/build/main.aleo');
        //const token_registry = file_to_string('../token_registry_workaround/build/main.aleo');
        
        console.log('Creating mint transaction...');
        console.log('Recipient address:', address);
        console.log('Amount:', amount);
        
        // Create and send the mint transaction using program manager
        const tx = await programManager.execute({
            programName: "bean_token.aleo",
            functionName: "mint_public",
            fee: 0.020,
            privateFee: false,
            inputs: [address, amount.endsWith("u128") ? amount : `${amount}u128`], // Format amount as u128
            //program: program,
            //imports: [token_registry],
        });

        console.log('Transaction ID:', tx);
        console.log('Mint transaction completed successfully');
    } catch (error) {
        console.error('Error executing mint transaction:', error.message);
        console.log('Error details:', error);
        process.exit(1);
    }
}

mintTokens();
