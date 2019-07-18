# occur-imenu
Show imenu in an occur buffer.
This library answers the question [How to show all functions in a javascript file](https://emacs.stackexchange.com/q/51686/2370).

The command <kbd>M-x</kbd> `occur-imenu` called in the buffer for the following javascript file `mymodule.js` (cited from the [english JavaScript Wikipedia page](https://en.wikipedia.org/wiki/JavaScript#Simple_examples)) generates the occur buffer `*Occur Imenu <mymodule.js>*` shown below.

```javascript

/* mymodule.js */
// This function remains private, as it is not exported
let sum = (a, b) => {
    return a + b;
}

// Export variables
export var name = 'Alice';
export let age = 23;

// Export named functions
export function add(num1, num2){
  return num1 + num2;
}

// Export class
export class Multiplication {
    constructor(num1, num2) {
       this.num1 = num1;
       this.num2 = num2;
    }

    add() {
        return sum(this.num1, this.num2);
    }
}
```

Contents of buffer `*Occur Imenu <mymodule.js>*`:

```javascript
* Occur Imenu For buffer mymodule.js *
Variables
      9:export var name = 'Alice';
Functions
     13:export function add(num1, num2){
```

The example shows that semantic analyzes only a part of JavaScript's function definitions.

# Installation
Put the file `occur-imenu.el` somewhere in your load path. Compile if you want and add `(require 'occur-imenu)` to your init file.

# Usage
In any buffer that supports `imenu` you can call <kbd>M-x</kbd> `occur-imenu` <kbd>RET</kbd> to obtain the Imenu in an Occur buffer.
