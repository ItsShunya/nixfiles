![nixfiles](https://socialify.git.ci/ItsShunya/nixfiles/image?custom_description=NixOS+dotfiles+for+all+my+machines&description=1&font=Raleway&forks=1&issues=1&language=1&logo=https%3A%2F%2Fcamo.githubusercontent.com%2F955fca7bc4a99f4142047a976fff46c50616dd7d2a20aa1bf36ea04104bb025c%2F68747470733a2f2f692e696d6775722e636f6d2f367146436c41312e706e67&name=1&owner=1&pattern=Signal&pulls=1&stargazers=1&theme=Light)


This repository contains the configuration files and scripts for managing my NixOS machines. It is designed for personal use but can serve as a reference for others interested in setting up and managing NixOS systems.

Feel free to use parts of this repository, but note that it is tailored to my specific needs and may require adjustments for your use case.

---

## Repository Structure

The repository is structured to allow easy management of multiple NixOS hosts, with a clear separation between core, optional, and host-specific configurations. Below is an overview of the key directories:

### Key Directories

- **`flake.nix`**: The entry point for the repository, defining the Nix flake configuration.
- **`docs/`**: Documentation for various configurations and troubleshooting guides..
- **`hosts/`**: Host-specific configurations.
  - Each subdirectory (e.g., `desktop/`, `server/`, `vm/`) contains settings unique to a specific machine.
  - Host configurations may include machine-specific options like `disko` or hardware drivers.
- **`modules/`**: Reusable configuration modules.
  - **`common/`**: User-specific configurations shared across machines.
    - Subdirectories for different users (e.g., `root/`, `me/`, `guest/`) and platforms (`nixos/`, `home/`).
  - **`nixos/`**: System-level configurations.
    - **`core/`**: Modules applied to all machines (e.g., hardware, kernel, shell, system).
    - **`optional/`**: Modules applied to specific machines (e.g., bootloader, WiFi, GPU drivers).
  - **`home/`**: Home-manager configurations.
    - **`core/`**: Modules applied to all users.
    - **`optional/`**: Modules for specific use cases (e.g., desktop environments, general software).
    - **`users/`**: User-specific configurations (e.g., `me/` with custom packages like Git).
- **`secrets/`**: Encrypted secrets managed with `sops`.
- **`.sops.yaml`**: Configuration file for `sops`.

### Configuration Philosophy

- **Core Modules (`core/`)**: Applied systematically to all machines.
- **Optional Modules (`optional/`)**: Applied to specific machines or use cases.
- **Host-Specific Configurations (`hosts/`)**: Applied only to a single machine.

This structure allows for easy scalability and modularity. Adding a new machine typically involves:
1. Creating a new subdirectory in `hosts/`.
2. Copying a template configuration.
3. Adding any required optional modules (e.g., drivers, WiFi).
4. Importing shared user configurations from `modules/common/users`.

---

## Initial Setup

To use a host configuration on a fresh NixOS installation, follow these steps:

1. **Set the Hostname**  
   Ensure the hostname is set correctly:  
   ```bash
   hostname <machine name>
   ```

2. **Connect to the Internet**  
   Verify that the machine has internet access and the necessary credentials to clone this repository.

3. **Update the Configuration**  
   Ensure the machine's configuration is up-to-date by pulling the latest changes from the repository.

4. **Backup Hardware Configuration**  
   Replace the generated `hardware-configuration.nix` file with the one specific to the host:
   ```bash
   # Overwrite hardware-configuration.nix file with the generated one
   cp /etc/nixos/hardware-configuration.nix \
      ./hosts/$(hostname)/hardware-configuration.nix

   # Commit and push the new file
   git commit -am "Add hardware-configuration for $(hostname)" && git push
   ```

5. **Deploy the Configuration**  
   Apply the configuration using the NixOS rebuild command:
   ```bash
   sudo nixos-rebuild switch --flake .#$(hostname)
   ```

---

## Current Hosts

| Configuration                       | Type      | Location    | VPN IP         | Description                  |
| ----------------------------------- | --------- | ----------- | -------------- | ---------------------------- |
| [shunya-dsktp](./hosts/desktop/shunya-dsktp)   | Desktop   | Local       | `10.9.97.152`  | Main desktop machine         |
| [nb250-10n](./hosts/server/nb250-10n)           | Server    | Local       | `10.9.97.185`  | Notebook acting as a server  |

Each host has a dedicated `README.md` file documenting the services and configurations specific to that machine.

---

## Continuous Integration (CI)

This repository uses a basic CI setup to validate configurations. The CI pipeline ensures that:

- The NixOS configurations are syntactically correct.
- Flake checks pass without errors.

To run the checks locally:
```bash
nix flake check
```

---

## Contributing

While this repository is primarily for personal use, I welcome constructive feedback, tips, and suggestions. If you notice areas for improvement or have ideas for better practices, feel free to open an issue or reach out.

---

## License

This repository is shared under the [Apache-2.0 License](./LICENSE). You are free to use and modify the code, but please give credit where it's due.

---

## Acknowledgments

Special thanks to the NixOS community for their excellent documentation and support, which made this setup possible.