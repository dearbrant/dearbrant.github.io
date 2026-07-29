# Theme profiles

本站保留两个可独立切换的定制主题：

- `dearbrant-papermod-dario`：基于 PaperMod，并采用 Dario 视觉样式
- `dearbrant-shibui`：基于 Shibui，并包含本站定制的首页、文章页和 CSS

## 本地预览

请先进入项目根目录：

```sh
cd /Users/brant/Documents/Project/dearbrant-blog
```

预览 PaperMod + Dario：

```sh
hugo server --environment dearbrant-papermod-dario
```

预览 Shibui：

```sh
hugo server --environment dearbrant-shibui
```

## 正式环境切换

GitHub Pages 使用 `.github/workflows/hugo.yml` 中的 `HUGO_THEME_PROFILE`。

保持当前线上主题：

```yaml
HUGO_THEME_PROFILE: dearbrant-papermod-dario
```

切换到定制版 Shibui：

```yaml
HUGO_THEME_PROFILE: dearbrant-shibui
```

修改这一行并部署前，应先用同名 `--environment` 在本地预览和构建。

## 文件归属

公共配置位于 `config/_default/hugo.toml`。

各主题配置分别位于：

- `config/dearbrant-papermod-dario/hugo.toml`
- `config/dearbrant-shibui/hugo.toml`

本站的主题定制分别位于：

- `themes/dearbrant-papermod-dario/`
- `themes/dearbrant-shibui/`

上游主题分别位于：

- `themes/PaperMod/`
- `themes/shibui/`

不要把主题专属的模板重新放回项目根目录的 `layouts/`，也不要把主题专属 CSS 放回项目根目录的 `assets/`。项目级文件优先级高于所有主题，可能在切换后继续覆盖另一个主题。

以后更新或更换主题时，应先检查项目根目录的 `layouts/` 和 `assets/`，并把定制内容保留在对应的 `dearbrant-*` 主题组件中。
