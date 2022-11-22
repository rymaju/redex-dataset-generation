# Redex Dataset Generation


## Install and Use

1. Install [Racket](https://racket-lang.org/)
2. Install [`redex`](https://pkgs.racket-lang.org/package/redex) via [`raco pkg install redex`](https://docs.racket-lang.org/pkg/getting-started.html#%28part._installing-packages%29) or installing via the DrRacket GUI.
3. Run `generate.rkt` either via `racket generate.rkt` or running the file in DrRacket.


The program should output three files matching those in `/example-output`:

-  `ds.json` which contains the natural language and DSL pairs in a canonical form for training a neural network.
- `src.txt` which is a newline seperated file of natural language input
- `tgt.txt` which is a newline seperate file of DSL language output

Each line in `src.txt` corresponds to the line at the same number in `tgt.txt`, zipping them into a JSON object results in a file equivalent to `ds.json`.

`ds.json` is a sequence of JSON Objects in the form:

``` json
{
  "translation": {
    "en": STRING,
    "<dsl>": STRING
  }
}
...
```
Where `<dsl>` may be a language of your choice, i.e. `regex`.

This is the canonical form for translation tasks, and integrates easily into the [HuggingFace Datasets interface](https://huggingface.co/docs/datasets/loading#json).

### Implementing a Dataset for your own language

See `generate.rkt`, in particular `K13-Regex` and `describe-k13regex`.

Implement a Redex model for your language, then grammar rules, and optionally a pretty printer for the language.

Currently this is _not_ paramaterized over an arbitrary language. Regex is baked in.

### Use in a translation task

[Example of use of this dataset in a translation task in Google Colab.](https://colab.research.google.com/drive/1QRCUvhok7L_FvJzKaXfto7MbKPe6gJcv#scrollTo=X4cRE8IbIrIV)
