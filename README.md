# DuckTongue
(You might check the Video Demo: URLHERE)

**Behold! This is DuckTongue! The ultimate dictionary of the Duck!**
![Our Holy Duck of David Malan](duck.jpg)

Hai! This is my final project for CS50.

With DuckTongue, you can store different words from the different languages via CLI or JSON API.

## The Actions
The logic is simply, you will send a name of action and the application will perform the action.

<table>
<thead>
  <tr>
      <th>Name</th>
      <th>Description</th>
      <th>Parameters</th>
  </tr>
</thead>
<tbody>
  <tr>
    <th>random</th>
    <td>Gives you a random word from database</td>
    <td>Need no parameters</td>
  </tr>
  <tr>
    <th>get</th>
    <td>Gets a word from database</td>
    <td>language (l), word (w), definition (d)</td>
  </tr>
  <tr>
    <th>put</th>
    <td>Puts a word from database</td>
    <td>language (l), word (w)</td>
  </tr>
  <tr>
    <th>remove</th>
    <td>Removes a word or language from database</td>
    <td>language (l), word (w, can be ignored if you want to remove whole language)</td>
  </tr>
  <tr>
    <th>create_language</th>
    <td>Creates a language</td>
    <td>language (l), definition(d)</td>
  </tr>
  <tr>
    <th>list</th>
    <td>List all languages</td>
    <td>Need no parameters</td>
  </tr>
  <tr>
    <th>server</th>
    <td>Launchs server</td>
    <td>Need no parameters</td>
  </tr>
</tbody>
</table>

## The CLI
The template:
```sh
duck_tongue action [parameters]
```
Choose an action from table, and pass their parameters like `-definition=foo` or `-d=foo`.

Some example:

```sh
# Create a language first
duck_tongue create_language --language="eo" --definition="Esperanto"
# Shorten the parameters as using their first letters
duck_tongue create_language -l="tr" -d="Türkçe"
# Check the languages
duck_tongue list # no parameter!
# Add new words, "w" for "word" and you can use "--word" instead of "-w"
duck_tongue put -l="eo" -w="Libereco" -d="Freedom - The state of being free, of not being imprisoned or enslaved."
# Get the word
duck_tongue get -l="eo" -w="Esperi"
# You can remove languages
duck_tongue remove -l="tr"
# Remove just a word
duck_tongue remove -l="eo" -w="Esperi"
# Get a random word from random language
duck_tongue random
# Also, you can directly call the application for the "random" action
duck_tongue
# You can launch the server like this:
duck_tongue server
```

## The JSON API
Instead of good old CLI, you may use the API. The API has an endpoint ("/") and you send JSON requests like this:
```Json
{
  "action": "put",
  "word": "Eliksiro",
  "definition": "Elixir - An elixir is a sweet liquid used for medical purposes, to be taken orally and intended to cure one's illness."
}
```
The default port is `4444`. You may change the port by setting the DUCK_PORT environmental variable like this:
```sh
DUCK_PORT=1234 duck_tongue server
```
## Building && Installation
__Note: This installation script and instructions are Unix specific__

You will need to install `elixir`, the compiler of Elixir programming language, and `mix`, the package manager.

You can check the installation page of Elixir:
https://elixir-lang.org/install.html

The `mix` executable should be installed with Elixir.

After installing Elixir, clone this repository. You can directly download from Github or run this command:
```sh
git clone https://github.com/Tarbetu/duck_tongue.git
```

Then, use this command to install DuckTongue:
```sh
cd duck_tongue
sh ./setup
```
To specialize the behavior of the `./setup` script, you might change the environment variables listed as below:
- `INSTALL_PATH`: The place where the binary placed. Default: "$HOME/.local/bin"
- `DUCK_MNESIA`: The place where the database stored. Default: "$HOME/.config" (will create DuckTongue subfolder)

## Some advice!
You can add this application to your `.bashrc`, so you can see a random word from DuckTongue when you open your (bash) shell. Example:
```echo "duck_tongue" > ~/.bashrc```

If you're fan of `fish` like me, you may use this command:
```fish
function fish_greeting; duck_tongue; end && funcsave fish_greeting
```

However, note that this application needs a bit of time to warm-up, so you might find it as a bit slow.