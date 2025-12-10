#!/bin/bash

# 替换底层库脚本
# 用法: ./scripts/replace_libcore.sh <fork-url> [commit-hash]
# 示例: ./scripts/replace_libcore.sh github.com/your-username/sing-box-uap v1.8.9-0.20240101000000-xxxxxxxxxxxx

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查参数
if [ $# -lt 1 ]; then
    echo -e "${RED}错误: 缺少参数${NC}"
    echo "用法: $0 <fork-url> [commit-hash]"
    echo "示例: $0 github.com/your-username/sing-box-uap v1.8.9-0.20240101000000-xxxxxxxxxxxx"
    exit 1
fi

FORK_URL=$1
COMMIT_HASH=${2:-""}

echo -e "${GREEN}开始替换底层库...${NC}"

# 1. 备份当前的 go.mod
echo -e "${YELLOW}步骤 1: 备份 go.mod${NC}"
cd libcore
if [ ! -f go.mod.backup ]; then
    cp go.mod go.mod.backup
    echo "已备份 go.mod 到 go.mod.backup"
fi

# 2. 修改 go.mod
echo -e "${YELLOW}步骤 2: 修改 go.mod${NC}"
if [ -n "$COMMIT_HASH" ]; then
    REPLACE_LINE="replace github.com/sagernet/sing-box => $FORK_URL $COMMIT_HASH"
else
    REPLACE_LINE="replace github.com/sagernet/sing-box => $FORK_URL"
fi

# 检查是否已有 replace 指令
if grep -q "replace github.com/sagernet/sing-box" go.mod; then
    # 替换现有的 replace 指令
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|replace github.com/sagernet/sing-box =>.*|$REPLACE_LINE|" go.mod
    else
        # Linux
        sed -i "s|replace github.com/sagernet/sing-box =>.*|$REPLACE_LINE|" go.mod
    fi
else
    # 添加新的 replace 指令
    echo "" >> go.mod
    echo "$REPLACE_LINE" >> go.mod
fi

echo "已更新 go.mod:"
grep "replace github.com/sagernet/sing-box" go.mod

# 3. 更新依赖
echo -e "${YELLOW}步骤 3: 更新 Go 依赖${NC}"
go mod tidy
go mod download

# 4. 返回项目根目录
cd ..

# 5. 编译 Android 库
echo -e "${YELLOW}步骤 4: 编译 Android 库${NC}"
echo "这可能需要几分钟时间..."
make build-android-libs

# 6. 验证
echo -e "${YELLOW}步骤 5: 验证${NC}"
if [ -f "android/app/libs/hiddify-core.aar" ]; then
    SIZE=$(du -h android/app/libs/hiddify-core.aar | cut -f1)
    echo -e "${GREEN}✓ AAR 文件已生成: android/app/libs/hiddify-core.aar (大小: $SIZE)${NC}"
else
    echo -e "${RED}✗ AAR 文件未找到${NC}"
    exit 1
fi

echo -e "${GREEN}完成! 底层库已成功替换。${NC}"
echo ""
echo "下一步:"
echo "1. 测试应用是否能正常编译: flutter build apk --debug"
echo "2. 验证 uap 协议是否正常工作"

