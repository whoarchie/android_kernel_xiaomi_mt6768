#!/usr/bin/bash
# Define some things
# Kernel common
export ARCH=arm64
export localversion=-X1.6
export LINKER="ld.lld"
# Telegram API
export SEND_TO_TG=1
export chat_id="-1002088104319"
export token="6410284454:AAESx0jgdzy-z4W0t-Oo53NaaS-mhGka8_4"
#KernelSU
#choice 'yes' or 'no
export KSU="yes"
# Specify compiler.
# 'sdclang' or 'gcc' or 'ew' or 'aosp' or 'azure' or 'neutron' or 'proton' or 'eva'
export COMPILER="ew"
#Any Kernel Branch
export dev_ak3="lancelot"
# Telegram && Output
export kver="Test"
export CODENAME="lancelot"
export DEVICE="Xiaomi Redmi 9 (${CODENAME})"
export BUILDER="Dreams"
export BUILD_HOST="Soulvibe"
export SUBLEVEL="v4.14.$(cat "${MainPath}/Makefile" | grep "SUBLEVEL =" | sed 's/SUBLEVEL = *//g')"
export TIMESTAMP=$(date +"%Y%m%d")-$(date +"%H%M%S")
export KBUILD_COMPILER_STRING=$(./clang/bin/clang -v 2>&1 | head -n 1 | sed 's/(https..*//' | sed 's/ version//')
export FW="R-Vendor"
export zipn="Paradox-Balanced-SLMK-${KSU}-${CODENAME}-${FW}-${TIMESTAMP}"
# Needed by script
CrossCompileFlagTriple="aarch64-linux-gnu-"
CrossCompileFlag64="aarch64-linux-gnu-"
CrossCompileFlag32="arm-linux-gnueabi-"
PROCS=$(nproc --all)

# Text coloring
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

# Check permission
script_permissions=$(stat -c %a "$0")
if [ "$script_permissions" -lt 777 ]; then
    echo -e "${RED}error:${NOCOLOR} Don't have enough permission"
    echo "run 'chmod 0777 origami_kernel_builder.sh' and rerun"
    exit 126
fi

# Check dependencies
if ! hash make curl bc zip 2>/dev/null; then
        echo -e "${RED}error:${NOCOLOR} Environment has missing dependencies"
        echo "Install make, curl, bc, and zip !"
        exit 127
fi

if [ ! -d "${PWD}/clang" ]; then
    echo -e "${RED}error:${NOCOLOR} /clang not found!"
    echo "have you clone the clang?"
    elif
    echo "Cloning Clang"
    if [ $COMPILER = "gcc" ]
	then
		msger -n "|| Cloning GCC 4.9 ||"
		git clone --depth=1 https://github.com/KudProject/aarch64-linux-android-4.9 gcc64
		git clone --depth=1 https://github.com/KudProject/arm-linux-androideabi-4.9 gcc32
  
  		# Toolchain Directory defaults to gcc
		GCC64_DIR=${PWD}/gcc64
		GCC32_DIR=${PWD}/gcc32

	elif [ $COMPILER = "ew" ]
	then
		msger -n "|| Cloning ElectroWizard clang ||"
   		git clone --depth=1 https://gitlab.com/Tiktodz/electrowizard-clang.git -b 16 --single-branch ewclang
  
		# Toolchain Directory defaults to ewclang
		TC_DIR=${PWD}/ewclang

	elif [ $COMPILER = "sdclang" ]
	then
		msger -n "|| Cloning SDClang ||"
		git clone --depth=1 https://gitlab.com/VoidUI/snapdragon-clang sdclang

  		msger -n "|| Cloning GCC 4.9 ||"
		git clone --depth=1 https://github.com/Kneba/aarch64-linux-android-4.9 gcc64
		git clone --depth=1 https://github.com/Kneba/arm-linux-androideabi-4.9 gcc32

		# Toolchain Directory defaults to sdclang
		TC_DIR=${PWD}/sdclang
  
		# Toolchain Directory defaults to gcc
		GCC64_DIR=${PWD}/gcc64
		GCC32_DIR=${PWD}/gcc32
  
     elif [ "$COMPILER" = "aosp" ]
     then
          msg "Clone latest aosp clang toolchain"
          wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r498229.tar.gz -O "aosp-clang.tar.gz"
          mkdir clang-llvm && tar -xf aosp-clang.tar.gz -C clang-llvm && rm -rf aosp-clang.tar.gz
          git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 -b lineage-19.1 gcc64
          git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 -b lineage-19.1 gcc32
  
     elif [ "$COMPILER" = "azure" ]
     then
          msg "Clone latest azure clang toolchain"
          git clone --depth=1 https://gitlab.com/Panchajanya1999/azure-clang.git azure
 
          # Toolchain Directory defaults to azure
		TC_DIR=${PWD}/azure
         
     elif [ "$COMPILER" = "neutron" ]
     then
          msg "Clone latest neutron clang toolchain"
          mkdir neutron
          cd neutron
          curl -LO "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman"
          chmod +x antman && bash antman -S=latest
          bash antman --patch=glibc
          cd ..

         # Toolchain Directory defaults to neutron
		      TC_DIR=${PWD}/neutron
          
     elif [ "$COMPILER" = "proton" ]
     then
          msg "Clone latest proton clang toolchain"
          git clone --depth=1 https://github.com/kdrag0n/proton-clang.git proton

         # Toolchain Directory defaults to proton
		TC_DIR=${PWD}/proton
  
     elif [ "$COMPILER" = "eva" ]
     then
          msg "Clone latest eva gcc toolchain"
          git clone --depth=1 https://github.com/mvaisakh/gcc-arm64.git gcc-arm64
          git clone --depth=1 https://github.com/mvaisakh/gcc-arm.git gcc-arm

     
  		# Toolchain Directory defaults to eva
		GCC64_DIR=${PWD}/gcc-arm64
		GCC32_DIR=${PWD}/gcc-arm
     fi
fi

if [ ! -d "${PWD}/anykernel" ]; then
    echo -e "${RED}error:${NOCOLOR} /anykernel not found!"
    echo "have you clone the anykernel?"
    then
    echo "Cloning AnyKernel3"
    any kernel : git clone  https://github.com/Soulvibe-Stuff/AnyKernel3.git -b ${dev_ak3} anykernel
fi
    
# Exit while got interrupt signal
exit_on_signal_interrupt() {
    echo -e "\n\n${RED}Got interrupt signal.${NOCOLOR}"
    exit 130
}
trap exit_on_signal_interrupt SIGINT

help_msg() {
    echo "Usage: bash kentot.sh --choose=[Function]"
    echo ""
    echo "Some functions on Soulvibe Kernel Builder:"
    echo "1. Build a whole Kernel"
    echo "2. Regenerate defconfig"
    echo "3. Open menuconfig"
    echo "4. Clean"
    echo ""
    echo "Place this script inside the Kernel Tree."
}

send_msg_telegram() {
    case "$1" in
    1) curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
                -d chat_id="$chat_id" \
                -d "disable_web_page_preview=true" \
                -d "parse_mode=html" \
                -d text="<b>~~~ SOULVIBE CI ~~~</b>
<b>Build Started on ${BUILD_HOST}</b>
<b>Build status</b>: <code>${kver}</code>
<b>Builder</b>: <code>${BUILDER}</code>
<b>Device</b>: <code>${DEVICE}</code>
<b>Kernel Version</b>: <code>$(make kernelversion 2>/dev/null)</code>
<b>Date</b>: <code>$(date)</code>
<b>Zip Name</b>: <code>${zipn}</code>
<b>Defconfig</b>: <code>${DEFCONFIG}</code>
<b>Compiler</b>: <code>${KBUILD_COMPILER_STRING}</code>
<b>Branch</b>: <code>$(git rev-parse --abbrev-ref HEAD)</code>
<b>Last Commit</b>: <code>$(git log --format="%s" -n 1): $(git log --format="%h" -n 1)</code>" \
                -o /dev/null
        ;;
    2) curl -s -F document=@./out/build.log "https://api.telegram.org/bot$token/sendDocument" \
                -F chat_id="$chat_id" \
                -F "disable_web_page_preview=true" \
                -F "parse_mode=html" \
                -F caption="Build failed after ${minutes} minutes and ${seconds} seconds." \
                -o /dev/null \
                -w "" >/dev/null 2>&1
        ;;
    3) curl -s -F document=@./out/target/"${zipn}".zip "https://api.telegram.org/bot$token/sendDocument" \
                -F chat_id="$chat_id" \
                -F "disable_web_page_preview=true" \
                -F "parse_mode=html" \
                -F caption="Build took ${minutes} minutes and ${seconds} seconds.
<b>SHA512</b>: <code>${checksum}</code>" \
                -o /dev/null \
                -w "" >/dev/null 2>&1

        curl -s -F document=@./out/build.log "https://api.telegram.org/bot$token/sendDocument" \
                -F chat_id="$chat_id" \
                -F "disable_web_page_preview=true" \
                -F "parse_mode=html" \
                -F caption="Build log" \
                -o /dev/null \
                -w "" >/dev/null 2>&1
        ;;
    esac
}

show_defconfigs() {
    defconfig_path="./arch/${ARCH}/configs"

    # Check if folder exists
    if [ ! -d "$defconfig_path" ]; then
        echo -e "${RED}FATAL:${NOCOLOR} Seems not a valid Kernel linux"
        exit 2
    fi

    echo -e "Available defconfigs:\n"

    # List defconfigs and assign them to an array
    defconfigs=($(ls "$defconfig_path"))

    # Display enumerated defconfigs
    for ((i=0; i<${#defconfigs[@]}; i++)); do
        echo -e "${LIGHTCYAN}$i: ${defconfigs[i]}${NOCOLOR}"
    done

    echo ""
    read -p "Select the defconfig you want to process: " choice

    # Check if the choice is within the range of files
    if [ $choice -ge 0 ] && [ $choice -lt ${#defconfigs[@]} ]; then
        export DEFCONFIG="${defconfigs[choice]}"
        echo "Selected defconfig: $DEFCONFIG"
    else
        echo -e "${RED}error:${NOCOLOR} Invalid choice"
        exit 1
    fi
}

kernelsu() {
    if [ "$KSU" = "yes" ];then
      KERNEL_VARIANT="${KERNEL_VARIANT}-KernelSU"
      if [ ! -f "${MainPath}/KernelSU/README.md" ]; then
        cd ${MainPath}
        curl -LSsk "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
        sed -i "s/CONFIG_KSU=n/CONFIG_KSU=y/g" arch/${ARCH}/configs/${DEFCONFIG}
      fi
      KERNELSU_VERSION="$((10000 + $(cd KernelSU && git rev-list --count HEAD) + 200))"
      git submodule update --init; cd ${MainPath}/KernelSU; git pull origin main; cd ..
    fi
}

compile_kernel() {
    rm ./out/arch/${ARCH}/boot/Image.gz-dtb 2>/dev/null

    export PATH="${PWD}/${TC_DIR}/bin/clang:${PATH}"
    export KBUILD_BUILD_USER=${BUILDER}
    export KBUILD_BUILD_HOST=${BUILD_HOST}
    export LOCALVERSION=${localversion}
    sed -i 's/^CONFIG_LOCALVERSION=".*"/CONFIG_LOCALVERSION="-Paradox"/' arch/${ARCH}/configs/${DEFCONFIG}

    make O=out ARCH=${ARCH} ${DEFCONFIG}

    START=$(date +"%s")

    make -j"$PROCS" O=out \
        ARCH=${ARCH} \
        LD="${LINKER}" \
        AR=llvm-ar \
        AS=llvm-as \
        NM=llvm-nm \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CC="clang" \
        CLANG_TRIPLE=${CrossCompileFlagTriple} \
        CROSS_COMPILE=${CrossCompileFlag64} \
        CROSS_COMPILE_ARM32=${CrossCompileFlag32} \
        CONFIG_NO_ERROR_ON_MISMATCH=y \
        CONFIG_DEBUG_SECTION_MISMATCH=y \
        V=0 2>&1 | tee out/build.log

    END=$(date +"%s")
    DIFF=$((END - START))
    export minutes=$((DIFF / 60))
    export seconds=$((DIFF % 60))
}

zip_kernel() {
    # Move kernel image to anykernel zip
if [ ! -f "./out/arch/${ARCH}/boot/Image.gz-dtb" ]; then
    cp ./out/arch/${ARCH}/boot/Image.gz ./anykernel
else
    cp ./out/arch/${ARCH}/boot/Image.gz-dtb ./anykernel
fi
    # Zip the kernel
    cd ./anykernel
    sed -i "s/kernel.string=.*/kernel.string=${zipn} ${SUBLEVEL} ${KSU} by ${BUILDER} for ${MODEL} (${CODENAME})/g" anykernel.sh
    zip -r9 "${zipn}".zip * -x .git README.md *placeholder
    cd ..

    # Generate checksum of kernel zip
    export checksum=$(sha512sum ./anykernel/"${zipn}".zip | cut -f1 -d ' ')

    if [ ! -d "./out/target" ]; then
        mkdir ./out/target
    fi

if [ ! -f "./out/arch/${ARCH}/boot/Image.gz-dtb" ]; then
    rm -f ./anykernel/Image.gz
else
    rm -f ./anykernel/Image.gz-dtb
fi

    # Move the kernel zip to ./out/target
    mv ./anykernel/${zipn}.zip ./out/target
}

build_kernel() {
    show_defconfigs

    echo -e "${LIGHTBLUE}================================="
    echo "Build Started on ${BUILD_HOST}"
    echo "Build status: ${kver}"
    echo "Builder: ${BUILDER}"
    echo "Device: ${DEVICE}"
    echo "Kernel Version: $(make kernelversion 2>/dev/null)"
    echo "Date: $(date)"
    echo "Zip Name: ${zipn}"
    echo "Defconfig: ${DEFCONFIG}"
    echo "Compiler: ${KBUILD_COMPILER_STRING}"
    echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
    echo "Last Commit: $(git log --format="%s" -n 1): $(git log --format="%h" -n 1)"
    echo -e "=================================${NOCOLOR}"

    if [ "$SEND_TO_TG" -eq 1 ]; then
        send_msg_telegram 1
    fi

    compile_kernel

    if [ ! -f "./out/arch/${ARCH}/boot/Image.gz-dtb" ] && [ ! -f "./out/arch/${ARCH}/boot/Image.gz" ]; then
        if [ "$SEND_TO_TG" -eq 1 ]; then
            send_msg_telegram 2
        fi
        echo -e "${LIGHTBLUE}================================="
        echo -e "${RED}Build failed${LIGHTBLUE} after ${minutes} minutes and ${seconds} seconds"
        echo "See build log for troubleshooting."
        echo -e "=================================${NOCOLOR}"
        exit 1
    fi

    zip_kernel

    echo -e "${LIGHTBLUE}================================="
    echo "Build took ${minutes} minutes and ${seconds} seconds."
    echo "SHA512: ${checksum}"
    echo -e "=================================${NOCOLOR}"

    if [ "$SEND_TO_TG" -eq 1 ]; then
        send_msg_telegram 3
    fi
}

regen_defconfig() {
show_defconfigs
make O=out ARCH=${ARCH} ${DEFCONFIG}
cp -rf ./out/.config ./arch/${ARCH}/configs/${DEFCONFIG}
}

open_menuconfig() {
show_defconfigs
make O=out ARCH=${ARCH} ${DEFCONFIG}
echo -e "${LIGHTGREEN}Note: Make sure you save the config with name '.config'"
echo -e "      else the defconfig will not saved automatically.${NOCOLOR}"
local count=8
while [ $count -gt 0 ]; do
    echo -ne -e "${LIGHTCYAN}menuconfig will be opened in $count seconds... \r${NOCOLOR}"
    sleep 1
    ((count--))
done
make O=out menuconfig
cp -rf ./out/.config ./arch/${ARCH}/configs/${DEFCONFIG}
}

execute_operation() {

   loop_helper() {
      read -p "Press enter to continue or type 0 for Quit: " a1
      clear
      if [[ "$a1" == "0" ]]; then
          exit 0
      else
          bash "$0"
      fi
   }

   case "$1" in
        1) clear
            build_kernel
            loop_helper
            ;;
        2) clear
            regen_defconfig
            loop_helper
             ;;
        3) clear
             open_menuconfig
             loop_helper
             ;;
        4) clear
            make clean && make mrproper
            loop_helper
            ;;
        5) exit 0 && clear ;;
        6) help_msg ;;
        *) echo -e "${RED}error:${NOCOLOR} Invalid selection." && exit 1 ;;
    esac
}

if [ $# -eq 0 ]; then
    clear
    echo -e "${LIGHTCYAN}What do you want to do today?"
    echo ""
    echo "1. Build a whole Kernel"
    echo "2. Regenerate defconfig"
    echo "3. Open menuconfig"
    echo "4. Clean"
    echo "5. Quit"
    echo -e "${NOCOLOR}"
    read -p "Choice the number: " choice
else
    case "$1" in
        --choose=1)
            choice=1
            ;;
        --choose=2)
            choice=2
            ;;
        --choose=3)
            choice=3
            ;;
        --choose=4)
            choice=4
            ;;
        --help)
            choice=6
            ;;
        *)
            echo -e "${RED}error:${NOCOLOR} Not a valid argument"
            echo "Try 'bash origami_kernel_builder.sh --help' for more information."
            exit 1
            ;;
    esac
fi

# Main script logic
execute_operation "$choice"
