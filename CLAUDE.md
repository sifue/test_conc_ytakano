# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 言語設定 (Language Configuration)

このプロジェクトは日本語環境での動作を前提としています。

- **コミュニケーション**: 日本語で対応してください
- **コメント**: コードコメントは日本語で記述
- **ドキュメント**: 技術文書は日本語で作成
- **エラーメッセージ**: 可能な限り日本語で表示
- **変数名・関数名**: 英語を使用（国際的な慣例に従う）

## プロジェクト概要
このプロジェクトは、オライリーから発売されている並行プログラミング入門のサンプルコード
https://github.com/oreilly-japan/conc_ytakano が各環境で動作するかを検証するプロジェクトです。

Windows(11,10)、Linux、macOS(Apple Sillicon)の各プラットフォームのDocker Desktop環境で、

```
docker buildx build --platform linux/amd64 -t univ/dev-env:x86_1.87 .
```

を実施してイメージをビルドした後、

```
docker run --platform linux/amd64 -it --rm -v "$(pwd)":/work -w /work univ/dev-env:x86_1.87 bash
```

でコンテナのサンプルを実行して、動作確認を行うbashシェルスクリプトを作成して欲しいです。


## 技術構成

Ubuntu 22.04 LTSをベースに、以下のツールをインストールして実行可能なようにしてあります。テストはbashスクリプトで実行されることを想定していますが、必要に応じて他のスクリプト言語（Perlなど）を使用しても構いません。構成はDoerfileに記載されています。

```
root@d128bf9f3af6:/work# nasm -v
NASM version 2.16.01
root@d128bf9f3af6:/work# as --version | head -1
GNU assembler (GNU Binutils for Ubuntu) 2.42
root@d128bf9f3af6:/work# gcc --version
gcc (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0
Copyright (C) 2023 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

root@d128bf9f3af6:/work# rustc --version
rustc 1.87.0 (17067e9ac 2025-05-09)
root@d128bf9f3af6:/work# cargo --version
cargo 1.87.0 (99624be96 2025-05-06)
root@d128bf9f3af6:/work# rustup show
Default host: x86_64-unknown-linux-gnu
rustup home:  /usr/local/rustup

installed toolchains
--------------------
1.87.0-x86_64-unknown-linux-gnu (active, default)

active toolchain
----------------
name: 1.87.0-x86_64-unknown-linux-gnu
active because: it's the default toolchain
installed targets:
  x86_64-unknown-linux-gnu
```

## 機能要件
- test.sh という名前のシェルスクリプトを作成
- スクリプトは、以下の要件を満たすこと
 - conc_ytakano ディレクトリ内のさまざまなCとRustのサンプルコードをエラーなくビルドできることを確認
 - conc_ytakanoフォルダ以下には、chapNのようなディレクトリある
   - chapNディレクトリ内には、N.{セクション番号_セクション名称}やchN_{セクション名称}の形で、C言語、Rust、アセンブリ言語のサンプルコードが含まれている、場合によってはMakefileやCargo.tomlがさらにサブディレクトリに入っている場合もある
   - C言語のサンプルコードは、Makefileを使用してビルドして検証する
   - またC言語のサンプルコードに関しては、最適化オプションをオフにしてx86のアセンブリが生成されることを確認する
   - Rustのサンプルコードは、Cargoを使用してビルドして検証する
- ビルドを実行して、成功したものを一覧で標準出力でわかりやすく表示
- 失敗したものがあれば、その内容を一覧化して詳細を表示、またはログファイルに出力

## 非機能要件
- テストスクリプトの実行方法をREADME.mdに記載
- できるだけみやすい対象プロジェクトのディレクトリ一覧の表示
- できるだけみやすいテスト結果の表示
- Gitで管理することを前提とするため、.gitignoreファイルを作成
- ログファイルを出力する場合はそれを.gitignoreに追加
- テストのスクリプトは、Dockerコンテナ内で実行されることを前提とする
