## Apps

- greetd
- regreet (https://github.com/rharish101/ReGreet)
- gnome-keyring
- gnome-keyring-pam
- seahorse (Passwords and Keys)
- fprintd
- fprintd-pam

## Setup

- `groupadd --system greeter`
- `useradd --system --no-create-home --shell /sbin/nologin -g greeter greeter`
- `systemctl set-default graphical.target`
- `systemctl enable greetd`
- `authselect enable-feature with-fingerprint`
