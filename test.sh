#!/bin/bash

# 並行プログラミング入門サンプルコードテストスクリプト
# Usage: ./test.sh

# カラー出力の設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログファイルの設定（絶対パスを使用）
BASE_DIR=$(pwd)
LOG_DIR="$BASE_DIR/test_logs"
SUCCESS_LOG="$LOG_DIR/success.log"
FAILURE_LOG="$LOG_DIR/failure.log"
DETAILED_LOG="$LOG_DIR/detailed.log"

# 統計変数
declare -i C_SUCCESS=0
declare -i C_TOTAL=0
declare -i RUST_SUCCESS=0
declare -i RUST_TOTAL=0
declare -i ASM_SUCCESS=0
declare -i ASM_TOTAL=0

# ログディレクトリの作成
mkdir -p "$LOG_DIR"

# ログファイルの初期化
echo "=== テスト実行開始: $(date) ===" > "$SUCCESS_LOG"
echo "=== テスト実行開始: $(date) ===" > "$FAILURE_LOG"
echo "=== 詳細ログ: $(date) ===" > "$DETAILED_LOG"

# 関数: ディレクトリ一覧を見やすく表示
show_directory_structure() {
    echo -e "${BLUE}=== プロジェクト構造 ===${NC}"
    if command -v tree >/dev/null 2>&1; then
        tree "$BASE_DIR/conc_ytakano" -d -L 3
    else
        find "$BASE_DIR/conc_ytakano" -type d -maxdepth 3 | sed 's|[^/]*/|  |g'
    fi
    echo ""
}

# 関数: Cプロジェクトのテスト
test_c_project() {
    local project_dir=$1
    local project_name=$2
    
    echo -e "${YELLOW}Testing C project: ${project_name}${NC}"
    echo "Testing C project: $project_name" >> "$DETAILED_LOG"
    
    cd "$project_dir" || return 1
    
    # Makefileの存在確認
    if [ ! -f "Makefile" ]; then
        echo -e "${RED}  ✗ Makefileが見つかりません${NC}"
        echo "FAILURE: $project_name - Makefileが見つかりません" >> "$FAILURE_LOG"
        cd - >/dev/null
        return 1
    fi
    
    # ビルドのテスト
    if make clean >/dev/null 2>&1 && make >> "$DETAILED_LOG" 2>&1; then
        echo -e "${GREEN}  ✓ ビルド成功${NC}"
        echo "SUCCESS: $project_name - ビルド成功" >> "$SUCCESS_LOG"
        
        # 最適化オフでのアセンブリ生成テスト（.sファイルがターゲットに含まれる場合）
        if grep -q "\.s" Makefile 2>/dev/null; then
            if make clean >/dev/null 2>&1 && CFLAGS="-O0" make >> "$DETAILED_LOG" 2>&1; then
                echo -e "${GREEN}  ✓ アセンブリ生成成功（最適化オフ）${NC}"
                echo "SUCCESS: $project_name - アセンブリ生成成功（最適化オフ）" >> "$SUCCESS_LOG"
                ((ASM_SUCCESS++))
            else
                echo -e "${RED}  ✗ アセンブリ生成失敗（最適化オフ）${NC}"
                echo "FAILURE: $project_name - アセンブリ生成失敗（最適化オフ）" >> "$FAILURE_LOG"
            fi
            ((ASM_TOTAL++))
        fi
        
        ((C_SUCCESS++))
        cd - >/dev/null
        return 0
    else
        echo -e "${RED}  ✗ ビルド失敗${NC}"
        echo "FAILURE: $project_name - ビルド失敗" >> "$FAILURE_LOG"
        cd - >/dev/null
        return 1
    fi
}

# 関数: Rustプロジェクトのテスト
test_rust_project() {
    local project_dir=$1
    local project_name=$2
    
    echo -e "${YELLOW}Testing Rust project: ${project_name}${NC}"
    echo "Testing Rust project: $project_name" >> "$DETAILED_LOG"
    
    cd "$project_dir" || return 1
    
    # Cargo.tomlの存在確認
    if [ ! -f "Cargo.toml" ]; then
        echo -e "${RED}  ✗ Cargo.tomlが見つかりません${NC}"
        echo "FAILURE: $project_name - Cargo.tomlが見つかりません" >> "$FAILURE_LOG"
        cd - >/dev/null
        return 1
    fi
    
    # ビルドのテスト
    if cargo clean >/dev/null 2>&1 && cargo build >> "$DETAILED_LOG" 2>&1; then
        echo -e "${GREEN}  ✓ ビルド成功${NC}"
        echo "SUCCESS: $project_name - ビルド成功" >> "$SUCCESS_LOG"
        ((RUST_SUCCESS++))
        cd - >/dev/null
        return 0
    else
        echo -e "${RED}  ✗ ビルド失敗${NC}"
        echo "FAILURE: $project_name - ビルド失敗" >> "$FAILURE_LOG"
        cd - >/dev/null
        return 1
    fi
}

# メイン処理開始
echo -e "${BLUE}=== 並行プログラミング入門サンプルコードテストスクリプト ===${NC}"
echo ""

# プロジェクト構造の表示
show_directory_structure

echo -e "${BLUE}=== テスト実行開始 ===${NC}"
echo ""

# conc_ytakanoディレクトリの存在確認
CONC_DIR="$BASE_DIR/conc_ytakano"
if [ ! -d "$CONC_DIR" ]; then
    echo -e "${RED}エラー: conc_ytakanoディレクトリが見つかりません${NC}"
    echo "CRITICAL: conc_ytakanoディレクトリが見つかりません" >> "$FAILURE_LOG"
    exit 1
fi

# 各章のディレクトリを処理
for chap_dir in "$CONC_DIR"/chap*; do
    if [ -d "$chap_dir" ]; then
        chap_name=$(basename "$chap_dir")
        echo -e "${BLUE}=== $chap_name ===${NC}"
        
        # 章ディレクトリ内のサブディレクトリを処理
        for sub_dir in "$chap_dir"/*; do
            if [ -d "$sub_dir" ]; then
                sub_name=$(basename "$sub_dir")
                
                # Makefileがある場合はCプロジェクトとしてテスト
                if [ -f "$sub_dir/Makefile" ]; then
                    ((C_TOTAL++))
                    test_c_project "$sub_dir" "$chap_name/$sub_name"
                fi
                
                # Cargo.tomlがある場合はRustプロジェクトとしてテスト
                if [ -f "$sub_dir/Cargo.toml" ]; then
                    ((RUST_TOTAL++))
                    test_rust_project "$sub_dir" "$chap_name/$sub_name"
                fi
                
                # サブディレクトリ内にRustプロジェクトがある場合
                for rust_project in "$sub_dir"/ch*; do
                    if [ -d "$rust_project" ] && [ -f "$rust_project/Cargo.toml" ]; then
                        ((RUST_TOTAL++))
                        rust_name=$(basename "$rust_project")
                        test_rust_project "$rust_project" "$chap_name/$sub_name/$rust_name"
                    fi
                done
            fi
        done
        echo ""
    fi
done

# appendix_Aも処理
APPENDIX_DIR="$CONC_DIR/appendix_A"
if [ -d "$APPENDIX_DIR" ]; then
    echo -e "${BLUE}=== appendix_A ===${NC}"
    if [ -f "$APPENDIX_DIR/Makefile" ]; then
        ((C_TOTAL++))
        test_c_project "$APPENDIX_DIR" "appendix_A"
    fi
    echo ""
fi

# 結果サマリーの表示
echo -e "${BLUE}=== テスト結果サマリー ===${NC}"
echo -e "C言語プロジェクト: ${GREEN}${C_SUCCESS}${NC}/${C_TOTAL} 成功"
echo -e "Rustプロジェクト:  ${GREEN}${RUST_SUCCESS}${NC}/${RUST_TOTAL} 成功"
if [ $ASM_TOTAL -gt 0 ]; then
    echo -e "アセンブリ生成:    ${GREEN}${ASM_SUCCESS}${NC}/${ASM_TOTAL} 成功"
fi

# 総合結果
total_success=$((C_SUCCESS + RUST_SUCCESS + ASM_SUCCESS))
total_tests=$((C_TOTAL + RUST_TOTAL + ASM_TOTAL))

if [ $total_success -eq $total_tests ]; then
    echo -e "${GREEN}🎉 全てのテストが成功しました！${NC}"
else
    echo -e "${YELLOW}⚠️  一部のテストが失敗しました。詳細は以下のログファイルを確認してください：${NC}"
    echo -e "  - 成功ログ: ${SUCCESS_LOG}"
    echo -e "  - 失敗ログ: ${FAILURE_LOG}"
    echo -e "  - 詳細ログ: ${DETAILED_LOG}"
fi

# ログファイルに結果サマリーを追記
{
    echo ""
    echo "=== テスト結果サマリー ==="
    echo "C言語プロジェクト: $C_SUCCESS/$C_TOTAL 成功"
    echo "Rustプロジェクト:  $RUST_SUCCESS/$RUST_TOTAL 成功"
    if [ $ASM_TOTAL -gt 0 ]; then
        echo "アセンブリ生成:    $ASM_SUCCESS/$ASM_TOTAL 成功"
    fi
    echo "総合:             $total_success/$total_tests 成功"
    echo "=== テスト実行終了: $(date) ==="
} >> "$SUCCESS_LOG"

{
    echo ""
    echo "=== テスト結果サマリー ==="
    echo "C言語プロジェクト: $C_SUCCESS/$C_TOTAL 成功"
    echo "Rustプロジェクト:  $RUST_SUCCESS/$RUST_TOTAL 成功"
    if [ $ASM_TOTAL -gt 0 ]; then
        echo "アセンブリ生成:    $ASM_SUCCESS/$ASM_TOTAL 成功"
    fi
    echo "総合:             $total_success/$total_tests 成功"
    echo "=== テスト実行終了: $(date) ==="
} >> "$FAILURE_LOG"

# 終了コード
if [ $total_success -eq $total_tests ]; then
    exit 0
else
    exit 1
fi