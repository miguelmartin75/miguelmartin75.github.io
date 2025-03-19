# Personal Website

My personal website http://miguelmartin75.github.io/

## usage

See [config.nims](./config.nims) for commands.

Initialize repo:
```
nim init
```

Run development server for local testing
```
nim dev
```

Publish site:
```
nim publish
```

Run production server (TODO)
```
nim prod
```

Generate site yourself:
```bash
nim gen
```

## TODOs

- [ ] better deployment https://sangsoonam.github.io/2019/02/08/using-git-worktree-to-deploy-github-pages.html
- [ ] regenerate route when source file changes
- [ ] refresh page if re-generated and route is on a browser page (websockets)
