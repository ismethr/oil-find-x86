# Oil Find website

The site uses Next.js App Router, React, and TypeScript. Use Node.js 22 and pnpm 11.

## Local development

From this directory, install dependencies and start the development server:

```sh
pnpm install --frozen-lockfile
pnpm dev
```

The Chinese home page is at `/`, the English home page is at `/en`, and each language has a changelog at `/changelog` or `/en/changelog`.

Run the checks and create a production build with:

```sh
pnpm test
pnpm typecheck
pnpm build
```

To serve a production build locally, run `pnpm start` after `pnpm build`.
