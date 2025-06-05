# standard_theme
**standard_theme** is the default, pre-installed theme of the [Dialogue Maker loader](https://github.com/DialogueMaker/loader). It is intended to be read by the [client](https://github.com/DialogueMaker/client).

standard_theme's purpose is to be an acceptable starting theme for developers who use Dialogue Maker. There shouldn't be any special backgrounds or images that grab too much attention. This theme should *just work*.

## Features
### Dialogue with Roblox's UI design language
standard_theme intends to be the starting point for Dialogue Maker users, so we're using a familiar color and style.

### Readable text by default
The dialogue text uses a pretty large text size with a cozy spacing between lines. This helps keep your dialogue readable to most users out-of-the-box. Feel free to change it using your settings though.

### Animated continue indicator
For player accessibility, an animated arrow appears at the bottom right of the dialogue box if there is another page or [Dialogue](https://github.com/DialogueMaker/dialogue) object in the chain.

### Full support for Dialogue Maker client settings
Speaker names, continue sounds, typewriter delay rates, the hits — all supported and implemented by standard_theme.

## Installation
### Dialogue Maker plugin
standard_theme is included in the Dialogue Maker loader. Run [Initialize Client]() to install or re-install it into your game.

### pesde
Run this command while in the same directory as your pesde.toml file:

```bash
pesde add dialoguemaker/standard_theme
```

You can also directly add it to your pesde.toml file's dependency list:

```toml
standard_theme = { name = "dialoguemaker/standard_theme", version = "^0.1.3" }
```

### Roblox Creator Store
standard_theme will be available on the Roblox Creator Store soon after v5.0.0 of the Dialogue Maker plugin is published.

### Wally
standard_theme is currently unavailable on [Wally](https://wally.run). standard_theme relies on [React Lua](https://github.com/jsdotlua/react-lua) as a peer dependency to ensure that the theme targets the correct React object. Since Wally doesn't officially support peer dependencies, Wally would return a new version of React that the client isn't using. Thus, support for Wally isn't in the plans right now.

## Development
### Install dependencies
This project uses [pesde](https://docs.pesde.dev/) as its package manager. Before working, you need to install the project's dependencies:

```bash
pesde install
```

### Start developing
After this point, you're all set to work on the theme! 

## Acknowledgments
standard_theme was created by [Christian Toney](https://github.com/Christian-Toney).