import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  testMatch: /.*\.spec\.ts/,
  use: {
    headless: false,
  },
  reporter: 'list',
  metadata: {
    tsconfig: './tsconfig.playwright.json',
  },
});