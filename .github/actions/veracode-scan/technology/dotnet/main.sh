#!/bin/sh -l

OUTPUT_PATH="dist/${TECHNOLOGY}"
sh -c "${BUILD_COMMAND} -o ${OUTPUT_PATH}"

dotnet tool install --global dotnet-ilrepack || echo "ILRepack already installed"
export PATH="$PATH:$HOME/.dotnet/tools"

cd "${OUTPUT_PATH}/"
PROJECT_DLLS=""
for PROJECT_DLL in *.dll; do
  if [ -f "${PROJECT_DLL%.dll}.pdb" ] && [ "${PROJECT_DLL}" != "${SOURCE_DIR}.dll" ]; then
    PROJECT_DLLS="${PROJECT_DLLS} ${PROJECT_DLL}"
  fi
done

if [ -n "${PROJECT_DLLS}" ]; then
  ilrepack \
    --out=${SOURCE_DIR}.merged.dll \
    --lib=. \
    ${SOURCE_DIR}.dll ${PROJECT_DLLS}

  if [ -f "${SOURCE_DIR}.merged.dll" ]; then
    mv ${SOURCE_DIR}.merged.dll ${SOURCE_DIR}.dll
    if [ -f "${SOURCE_DIR}.merged.pdb" ]; then
      mv ${SOURCE_DIR}.merged.pdb ${SOURCE_DIR}.pdb
    fi

    for PROJECT_DLL in ${PROJECT_DLLS}; do
      rm -f "${PROJECT_DLL}" "${PROJECT_DLL%.dll}.pdb"
    done
  else
    echo "ILRepack merge failed, keeping individual assemblies"
  fi
else
  echo "No additional project assemblies to merge"
fi

cd - > /dev/null

zip -r "${OUTPUT_PATH}.zip" "${OUTPUT_PATH}/" \
&& rm -rf "${OUTPUT_PATH}" \
&& mkdir -p "${OUTPUT_PATH}" \
&& mv "${OUTPUT_PATH}.zip" "${OUTPUT_PATH}/"

echo "--> ${TECHNOLOGY} output: ${OUTPUT_PATH}"
