import { readFileSync } from 'fs';
import { join } from 'path';

export function file_to_string(filename) {
    try {
        const filePath = join(process.cwd(), filename);
        return readFileSync(filePath, 'utf8');
    } catch (error) {
        console.error(`Error reading file ${filename}:`, error);
        throw error;
    }
}
