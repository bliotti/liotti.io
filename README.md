# Personal Website

Fork of [raphjaph/website](https://github.com/raphjaph/website).

This repository contains the source for a personal website built with [Zola](https://www.getzola.org/), a static site generator. The project follows the standard Zola layout where content is written in Markdown, templates are rendered with [Tera](https://tera.netlify.app/), and static assets are copied as‑is.

## Project Structure

```
config.toml         # Zola configuration
content/            # Markdown pages and sections
templates/          # Tera HTML templates
static/             # CSS, images, scripts, fonts
justfile            # helper commands
.github/workflows/  # GitHub Actions for deployment
```

- **config.toml**: sets the site title, base URL and exposes variables under `[extra]`.
- **content/**: all Markdown files. Each directory is a section or page.
- **templates/**: reusable HTML templates. `base.html` defines the global layout and includes a script that picks a random link from `bookmarks.txt`.
- **static/**: files copied verbatim to the final site such as stylesheets, fonts and the installation script referenced from the navbar.
- **justfile**: convenience commands like `just serve` to run Zola locally and `just fmt` to format the code with Prettier.
- **GitHub Actions**: `.github/workflows/static.yml` deploys the site to GitHub Pages when the `main` branch is pushed.

## Development

1. Install Zola.
2. Run `just serve` to build and serve the site locally. The current git commit is passed via the `GIT_SHA` environment variable so it can be displayed in the footer.
3. Edit Markdown content under `content/` or templates under `templates/`.
4. Static assets live in `static/`.

Pushing to `main` triggers the GitHub Action to rebuild and publish the site to the `gh-pages` branch.

## Next Steps

- See [Zola’s documentation](https://www.getzola.org/documentation/) to learn more about sections, pages and templates.
- Customize the design by editing `static/css/gry.min.css` or adding new styles.
- Review `static/install.sh` if you plan to maintain the installation script linked from the navbar.
- Expand the content sections such as the bookshelf or Bitcoin resources.

Happy hacking!
