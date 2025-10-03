import { test } from '@playwright/test';
import { generateLuaDB } from 'generate-lua-db/generate-db';

test('generate db', ({}) => {
    generateLuaDB();
})