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

## 重要な注意事項

### プラットフォーム対応
- **対象環境**: x86_64 (amd64) プラットフォーム専用
- **除外項目**: 
  - `appendix_A` ディレクトリは ARM64 アセンブリのため、x86_64 環境では動作しません
  - `chap6/ch6_mult` プロジェクト（ARM64版）は x86_64 環境では除外されます
  - `chap6/ch6_mult-x86_64-linux` プロジェクトは x86_64 アセンブリのため動作します
  - `chap7/7.3/ch7_3_lockfree` プロジェクトも ARM64 アセンブリのため、x86_64 環境では除外されます

### 書籍コードの互換性
このプロジェクトは書籍のサンプルコードを**一切変更せずに**動作させることを目的としています。互換性確保のため、以下の調整を行っています：

- **Rust バージョン**: 1.70.0 を使用（最新版 1.87.0 ではなく）
- **ビルドツール**: 必要な依存関係をDocker環境に事前インストール

## セットアップ

### 1. サンプルコードの取得

並行プログラミング入門のサンプルコードを取得します：

```bash
git clone https://github.com/oreilly-japan/conc_ytakano.git
```

### 2. Dockerイメージのビルド

```bash
docker buildx build --platform linux/amd64 -t univ/dev-env:x86_1.70 .
```

### 3. コンテナの起動とテスト実行

#### Linux/macOS環境の場合
```bash
docker run --platform linux/amd64 -it --rm -v "$(pwd)":/work -w /work univ/dev-env:x86_1.70 bash
```

#### Windows PowerShell環境の場合
```powershell
docker run --platform linux/amd64 -it --rm -v "${PWD}:/work" -w /work univ/dev-env:x86_1.70 bash
```

#### Windowsコマンドプロンプト環境の場合
```cmd
docker run --platform linux/amd64 -it --rm -v "%cd%:/work" -w /work univ/dev-env:x86_1.70 bash
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

**ベースイメージ**: Ubuntu 24.04 LTS

**インストール済みツール**：
- **NASM**: version 2.16.01 (アセンブリアセンブラ)
- **GNU Assembler**: version 2.42 (GASアセンブラ)
- **GCC**: version 13.3.0 (C/C++コンパイラ、32bit/64bit対応)
- **Rust**: version 1.70.0 (書籍サンプルコード互換バージョン)
- **Cargo**: version 1.70.0 (Rustパッケージマネージャ)
- **Rust Nightly**: 特定プロジェクト用（ch7_3_lockfree）
- **binutils**: アーカイブツール (arコマンド含む)

### バージョン選択の理由

**Rust 1.70.0 を選択した理由**：
1. **Tokio互換性**: chap5/5.4 系プロジェクトで必要な最小バージョン
2. **デュアルアプローチ**: 安定版(1.70.0) + Nightly(特定プロジェクト用)
3. **書籍執筆時期**: サンプルコードが想定する Rust バージョンとの互換性確保

**特別な対応**：
- **binutils**: アーカイブ作成用 (`ar` コマンド)
- **Nightly Rust**: `chap7/7.3/ch7_3_lockfree` の `#![feature(asm)]` 対応
- **Lint無効化**: `chap4/4.1/ch4_1_rwlock_2_2` の `let_underscore_lock` 対応
- **プロジェクト除外**: ARM64 アセンブリプロジェクトの自動スキップ

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

#### Linux/macOS環境
```bash
# Dockerイメージをビルド
docker buildx build --platform linux/amd64 -t univ/dev-env:x86_1.70 .

# コンテナを起動してテスト実行
docker run --platform linux/amd64 -it --rm -v "$(pwd)":/work -w /work univ/dev-env:x86_1.70 ./test.sh
```

#### Windows PowerShell環境
```powershell
# Dockerイメージをビルド
docker buildx build --platform linux/amd64 -t univ/dev-env:x86_1.70 .

# コンテナを起動してテスト実行
docker run --platform linux/amd64 -it --rm -v "${PWD}:/work" -w /work univ/dev-env:x86_1.70 ./test.sh
```

#### Windowsコマンドプロンプト環境
```cmd
REM Dockerイメージをビルド
docker buildx build --platform linux/amd64 -t univ/dev-env:x86_1.70 .

REM コンテナを起動してテスト実行
docker run --platform linux/amd64 -it --rm -v "%cd%:/work" -w /work univ/dev-env:x86_1.70 ./test.sh
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
C言語プロジェクト: 8/8 成功
Rustプロジェクト:  37/37 成功
アセンブリ生成:    2/2 成功
🎉 全てのテストが成功しました！

注意: appendix_A, chap6/ch6_mult, chap7/7.3/ch7_3_lockfree は ARM64 アセンブリのため x86_64 環境ではスキップされますが、成功としてカウントされます
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

4. **互換性に関する問題**
   - **Rust バージョンエラー**: Docker環境は Rust 1.70.0 を使用（最新版使用時は互換性問題が発生）
   - **ARM64 アセンブリエラー**: `appendix_A` は x86_64 環境では動作しません（テスト対象から除外済み）
   - **リンクエラー**: `binutils` パッケージが正しくインストールされているか確認

### Windows環境での問題

5. **`docker: invalid reference format` エラー**
   - **原因**: PowerShellでの変数展開構文の違い
   - **解決方法**: 
     - PowerShell: `"${PWD}:/work"` を使用
     - コマンドプロンプト: `"%cd%:/work"` を使用
     - 従来の `"$(pwd)":/work` はLinux/macOS専用

6. **パス区切り文字の問題**
   - Windowsでは区切り文字が異なる場合があります
   - Docker for Windowsを使用時は上記の変数展開方法を使用してください

7. **行末文字の問題**
   - Gitがテキストファイルの行末を変換している場合があります
   - 必要に応じて `git config core.autocrlf false` を設定してください

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