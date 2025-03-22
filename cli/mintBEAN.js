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
        console.log('ENDPOINT:', process.env.ENDPOINT);
        console.log('NETWORK:', process.env.NETWORK);

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
        // const tx = await programManager.execute({
        const tx = await programManager.buildExecutionTransaction({
            programName: "bean_token.aleo",
            functionName: "mint_public",
            fee: 100.0,
            privateFee: false,
            inputs: [address, amount.endsWith("u128") ? amount : `${amount}u128`], // Format amount as u128
            //program: program,
            //imports: [token_registry],
        });

        // console.log('Transaction:', tx.toString());
        console.log('Mint transaction completed successfully');
        console.log('--------------------------------------------');

        // No need to submit the transaction - execute() already does that.
        // But, it's needed for buildExecutionTransaction()
        const stxid = await programManager.networkClient.submitTransaction(tx);
        console.log('Transaction submitted:', stxid);
        console.log('--------------------------------------------');

        // Wait for the transaction to be confirmed
        // This returns HTTP 500 error, most likely do to a bug in the SDK. The transaction is not successful.
        // If we do the same from the "leo" CLI, it works fine.
        // Moreover, "leo query transaction <txid>" on this transaction returns HTTP 500 error as well,
        // but on non-existing transactions, it returns HTTP 400.
        const ctx = await programManager.networkClient.waitForTransactionConfirmation(stxid, 1000, 3000);
        console.log('Transaction confirmed:', ctx);
        console.log('--------------------------------------------');
    } catch (error) {
        console.error('Error executing mint transaction:', error.message);
        console.log('Error details:', error);
        process.exit(1);
    }
}

mintTokens();
