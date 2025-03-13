# Poxi: A Package Manager Helper for Arch Linux

Poxi is a command-line utility designed to simplify and enhance the package management experience on Arch Linux and its derivatives. It acts as a helper, wrapping around Pacman and popular AUR helpers like Paru and Yay, providing a more user-friendly and efficient way to manage packages.

## Features

*   **Interactive Package Selection:** Poxi leverages `fzf` to provide an interactive, fuzzy-finding interface for selecting packages to install or remove.
*   **AUR Support:**  It automatically detects and utilizes AUR helpers (Paru or Yay) if available, seamlessly integrating AUR package management with Pacman.
*   **Package Information Preview:** When selecting packages, Poxi displays detailed package information using Pacman's `-Si` option, giving you a quick overview of each package.
*   **Configuration via JSON:** Poxi uses a `packages.json` file (located in `$HOME/poxi/packages.json`) to store and manage a list of your preferred packages.
*   **Command-Line Options:**
    *   `-v` or `--version`: Display the current Poxi version.
    *   `-h` or `--help`: Show the help message.
    *   `-a` or `--accept-all`: Automatically answer "yes" to any confirmation prompts during package installation/removal.
    *   `-f` or `--file`: Specify a custom JSON file to use instead of the default.
*   **Easy Installation and Uninstallation**: provides makefile and user level installation with curl or wget command.

## Commands

*   **`install`:** Installs specified packages. If no packages are specified, it launches `fzf` to select packages interactively. If you use the option `--file` or `-f`, the packages list to be installed should be in `poxi_installed` key on json file.
*   **`remove`:** Removes specified packages. If no packages are specified, it launches `fzf` to select installed packages interactively.If you use the option `--file` or `-f`, the packages list to be removed should be in `poxi_installed` key on json file.
*   **`update`:** Updates the entire system (equivalent to `sudo pacman -Syu` or the equivalent in your AUR helper).

## Dependencies

Poxi relies on the following tools:

*   **Bash:** The shell environment.
*   **Pacman:** The Arch Linux package manager.
*   **jq:** A lightweight and flexible command-line JSON processor.
*   **fzf:** A general-purpose command-line fuzzy finder.
* **moreutils:** Collection of command-line tools.

**Optional dependencies:**
*   **paru/yay:** AUR helpers.

## Installation

There are multiple ways to install Poxi:

### 1. Using the Makefile (Recommended)

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/su-xixo/poxi.git
    cd poxi
    ```

2.  **Install using makefile:**

    ```bash
    make install
    ```
    This will install `poxi` in your `$HOME/.local/bin` and required files in `$HOME/.local/share/poxi`.

3.  **uninstall using makefile:**
    ```bash
    make uninstall
    ```

### 2. User Level Installation (One-Liner)

   You can also install Poxi directly from the command line using `curl` or `wget`:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/su-xixo/poxi/refs/heads/master/install.sh | bash -s install


<!-- # Poxi: A Package Manager Helper for Arch Linux

Poxi is a command-line utility designed to simplify and enhance the package management experience on Arch Linux and its derivatives. It acts as a helper, wrapping around Pacman and popular AUR helpers like Paru and Yay, providing a more user-friendly and efficient way to manage packages.

## Features

*   **Interactive Package Selection:** Poxi leverages `fzf` to provide an interactive, fuzzy-finding interface for selecting packages to install or remove.
*   **AUR Support:**  It automatically detects and utilizes AUR helpers (Paru or Yay) if available, seamlessly integrating AUR package management with Pacman.
*   **Package Information Preview:** When selecting packages, Poxi displays detailed package information using Pacman's `-Si` option, giving you a quick overview of each package.
*   **Configuration via JSON:** Poxi uses a `packages.json` file (located in `$HOME/poxi/packages.json`) to store and manage a list of your preferred packages.
*   **Command-Line Options:**
    *   `-v` or `--version`: Display the current Poxi version.
    *   `-h` or `--help`: Show the help message.
    *   `-a` or `--accept-all`: Automatically answer "yes" to any confirmation prompts during package installation/removal.
    *   `-f` or `--file`: Specify a custom JSON file to use instead of the default.
*   **Easy Installation and Uninstallation**: provides makefile to install and uninstall

## Commands

*   **`install`:** Installs specified packages. If no packages are specified, it launches `fzf` to select packages interactively. If you use the option `--file` or `-f`, the packages list to be installed should be in `poxi_installed` key on json file.
*   **`remove`:** Removes specified packages. If no packages are specified, it launches `fzf` to select installed packages interactively.If you use the option `--file` or `-f`, the packages list to be removed should be in `poxi_installed` key on json file.
*   **`update`:** Updates the entire system (equivalent to `sudo pacman -Syu` or the equivalent in your AUR helper).

## Dependencies

Poxi relies on the following tools:

*   **Bash:** The shell environment.
*   **Pacman:** The Arch Linux package manager.
*   **jq:** A lightweight and flexible command-line JSON processor.
*   **fzf:** A general-purpose command-line fuzzy finder.
* **moreutils:** Collection of command-line tools.

**Optional dependencies:**
*   **paru/yay:** AUR helpers.

## Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/su-xixo/poxi.git
    cd poxi
    ```

2.  **Install using makefile:**

    ```bash
    make install
    ```
    This will install `poxi` in your `$HOME/.local/bin` and required files in `$HOME/.local/share/poxi`.

3.  **uninstall using makefile:**
    ```bash
    make uninstall
    ```

## 2. User Level Installation (One-Liner)

   You can also install Poxi directly from the command line using `curl` or `wget`:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/su-xixo/poxi/refs/heads/master/install.sh | bash -s install
   ``` -->

## Configuration

Poxi uses a JSON file (`$HOME/poxi/packages.json`) to manage package groups and installed packages. If the file does not exist, Poxi will create it with a default structure:

```json
{
    "required": {
        "editor": ["neovim", "helix", "micro"],
        "terminal": ["alacritty", "kitty"],
        "utilites": ["moreutils", "fzf", "eza", "zoxide", "zsh"]
    },
    "installed": []
}
