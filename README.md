# notion.vim

## Description
notion.vim is a notion-like note taking system, the main feature of which is
the tree-like structure of notes.

Here one note can contain another one, which can be a more detailed explanation
of some point in the parent one, or the parent one can be a list of the child
notes with some short description etc.

This feature gives a lot of flexibility on organizing your notes. Here you can
create a non-graphical mindmap which is a lot more convenient to read despite
its size.

It's made as a plugin for vim text editor, so at least basic knowledge for vim
is required.

## How to use

At the first use it opens your root note, which is empty by default. To add a
new note you should write \*note_name\* where note_name is the name of your new
note.

To go to the new note move the cursor to its name and type `ef` on keyboard.
This command throuws you to the new empty note.

To go back to the root note type `eu`. The other ways to do that are `eh` (go
home) and `eb` (go back by history).

To move, rename or create a link to your note you should choose it first. Move
the cursor to the name of the note and type `ec` to make the plugin choose the
file.

To move it go somewhere else, type the name of the note in the form as mentioned
before, move the cursor on it, and type `en`.

To rename it do the same, but within the same note.

To create a link type the name of the link, move the cursor on it, and type
`el`.

To search through notes recursively type `es`, type the keyword, then choose the
right result. It will move you to the choosen note.

To remove a note move the cursor on it and type `er`, and now you can delete its
name, since the note doesn't exist now.

## How to install

On the command line:
```
mkdir -p documents/notion
cd documents/notion
git clone https://github.com/dimarogiv/notion.vim.git
echo 'alias note="vim -s documents/notion/.notion.vim" >> ~/.bashrc
source ~/.bashrc
```

Now, to launch it just type `note` on the command line.

## Current status

The basic functionality is done now, so the plugin is rather minimalistic.

Adding new functionality is not expected in the near future, since I decided to
continue development of the project in Lua language and for Neovim, since it
works much faster, the language is much more flexible and has much more
functions.

Now I'm adapting the plugin for easier installation and debugging.

For the new and maintained version see (notion.lua)[https://github.com/dimarogiv/notion.lua]
