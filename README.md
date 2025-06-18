# 並行プログラミング入門サンプルコードテストプロジェクト

このプロジェクトは、オライリーから発売されている「並行プログラミング入門」のサンプルコードが各環境で正常に動作するかを検証するためのプロジェクトです。

## 概要

本プロジェクトは以下の環境での動作確認を行います：
- Windows (11, 10)
- Linux
- macOS (Apple Silicon)

各プラットフォームのDocker Desktop環境で、並行プログラミング入門のサンプルコードのビルドと実行を自動テストします。

## 前提条件

- Docker Desktop がインストールされていること
- 対象プラットフォームで `docker buildx` コマンドが使用可能であること

## セットアップ

### 1. サンプルコードの取得

並行プログラミング入門のサンプルコードを取得します：

```bash
git clone https://github.com/oreilly-japan/conc_ytakano.git
```

### 2. Dockerイメージのビルド

```bash
docker buildx build --platform linux/amd64 -t univ/dev-env:x86_1.87 .
```

### 3. コンテナの起動とテスト実行

```bash
docker run --platform linux/amd64 -it --rm -v "$(pwd)":/work -w /work univ/dev-env:x86_1.87 bash
```

コンテナ内で以下のコマンドを実行してテストを開始します：

```bash
./test.sh
```

## テストスクリプトについて

### 機能

`test.sh` スクリプトは以下の機能を提供します：

- **プロジェクト構造の表示**: conc_ytakano ディレクトリ内の構造を見やすく表示
- **Cプロジェクトのテスト**: 
  - Makefile を使用したビルドテスト
  - 最適化オプションをオフにしたx86アセンブリ生成の確認
- **Rustプロジェクトのテスト**: 
  - Cargo を使用したビルドテスト
- **詳細なログ出力**: 成功・失敗の詳細をログファイルに記録

### テスト対象

以下のディレクトリ構造のプロジェクトをテストします：

```
conc_ytakano/
├── chap2/
│   └── 2.2/          # C言語サンプル（Makefile）
├── chap3/
│   ├── 3.2/          # C言語サンプル（Makefile）
│   ├── 3.3/          # C言語サンプル（Makefile）
│   ├── 3.4/          # C言語サンプル（Makefile）
│   ├── 3.5/          # C言語サンプル（Makefile）
│   ├── 3.6/          # C言語サンプル（Makefile）
│   ├── 3.7/          # C言語サンプル（Makefile）
│   ├── 3.8/          # Rustサンプル（複数のCargo.toml）
│   └── 3.9/          # Rustサンプル（Cargo.toml）
├── chap4/
│   ├── 4.1/          # Rustサンプル（複数のCargo.toml）
│   ├── 4.3/          # Rustサンプル（Cargo.toml）
│   ├── 4.4/          # C/Rustサンプル（Makefile, Cargo.toml）
│   ├── 4.5/          # C言語サンプル（Makefile）
│   ├── 4.6/          # C/Rustサンプル（Makefile, Cargo.toml）
│   └── 4.7/          # Rustサンプル（Cargo.toml）
├── chap5/            # Rustサンプル（複数のCargo.toml）
├── chap6/            # Rustサンプル（複数のCargo.toml）
├── chap7/            # Rustサンプル（複数のCargo.toml）
├── chap8/            # Rustサンプル（複数のCargo.toml）
└── appendix_A/       # C言語サンプル（Makefile）
```

### 出力形式

テスト実行時は以下の情報が表示されます：

- **プロジェクト構造**: ディレクトリツリー形式で表示
- **テスト進行状況**: 各プロジェクトのビルド結果をリアルタイム表示
- **結果サマリー**: 
  - C言語プロジェクトの成功/総数
  - Rustプロジェクトの成功/総数
  - アセンブリ生成の成功/総数（該当する場合）

### ログファイル

テスト実行後、以下のログファイルが `test_logs/` ディレクトリに生成されます：

- `success.log`: 成功したテストの一覧
- `failure.log`: 失敗したテストの一覧と詳細
- `detailed.log`: 全テストの詳細実行ログ

## 技術構成

### Docker環境

ベースイメージ: Ubuntu 22.04 LTS

インストール済みツール：
- **NASM**: version 2.16.01
- **GNU Assembler**: version 2.42 
- **GCC**: version 13.3.0
- **Rust**: version 1.87.0
- **Cargo**: version 1.87.0

### テスト仕様

- **C言語プロジェクト**: 
  - Makefileを使用してビルド
  - `-O0`オプションでアセンブリ生成テスト
- **Rustプロジェクト**: 
  - `cargo build`でビルドテスト
- **エラーハンドリング**: 
  - ビルド失敗時の詳細ログ出力
  - テスト継続実行

## 使用例

### 基本的な使用方法

```bash
# Dockerイメージをビルド
docker buildx build --platform linux/amd64 -t univ/dev-env:x86_1.87 .

# コンテナを起動してテスト実行
docker run --platform linux/amd64 -it --rm -v "$(pwd)":/work -w /work univ/dev-env:x86_1.87 ./test.sh
```

### 出力例

```
=== 並行プログラミング入門サンプルコードテストスクリプト ===

=== プロジェクト構造 ===
conc_ytakano
├── chap2
├── chap3
├── chap4
├── chap5
├── chap6
├── chap7
├── chap8
├── appendix_A
└── docs

=== テスト実行開始 ===

=== chap2 ===
Testing C project: chap2/2.2
  ✓ ビルド成功
  ✓ アセンブリ生成成功（最適化オフ）

=== chap3 ===
Testing C project: chap3/3.2
  ✓ ビルド成功
  ✓ アセンブリ生成成功（最適化オフ）
...

=== テスト結果サマリー ===
C言語プロジェクト: 15/15 成功
Rustプロジェクト:  28/28 成功
アセンブリ生成:    8/8 成功
🎉 全てのテストが成功しました！
```

## トラブルシューティング

### よくある問題

1. **Dockerイメージビルド失敗**
   - Docker Desktopが起動していることを確認
   - `docker buildx` コマンドが利用可能か確認

2. **テスト実行時の権限エラー**
   - テストスクリプトに実行権限があることを確認: `chmod +x test.sh`

3. **一部のビルドが失敗する場合**
   - `test_logs/failure.log` で詳細なエラー内容を確認
   - `test_logs/detailed.log` でビルドログを確認

### ログファイルの確認

失敗した場合は以下のログファイルを確認してください：

```bash
# 失敗したテストの確認
cat test_logs/failure.log

# 詳細なビルドログの確認
cat test_logs/detailed.log
```

## ライセンス

このプロジェクトは並行プログラミング入門のサンプルコードの動作確認を目的としています。
元のサンプルコードのライセンスについては `conc_ytakano/LICENSE` を参照してください。