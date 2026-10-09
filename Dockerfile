# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.10.0-base

# build-time tokens for gated downloads are read from BuildKit secret
# mounts — they are never written to a layer or to image history.
# pass via: docker buildx build --secret id=hf_token,env=HF_TOKEN .

# install custom nodes into comfyui
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts /comfyui/custom_nodes/ComfyUI-Custom-Scripts
RUN git clone https://github.com/ClownsharkBatwing/RES4LYF /comfyui/custom_nodes/RES4LYF
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use /comfyui/custom_nodes/ComfyUI-Easy-Use
RUN git clone https://github.com/rgthree/rgthree-comfy /comfyui/custom_nodes/rgthree-comfy
RUN git clone https://github.com/boobkake22/ComfyUI-FilmGrainLTXV /comfyui/custom_nodes/ComfyUI-FilmGrainLTXV
RUN comfy node install --exit-on-fail color-correct-gpu --mode remote
RUN git clone https://github.com/boobkake22/ComfyUI-QuickWatermark /comfyui/custom_nodes/ComfyUI-QuickWatermark
RUN git clone https://github.com/M1kep/ComfyLiterals /comfyui/custom_nodes/ComfyLiterals
RUN git clone https://github.com/boobkake22/ComfyUI-SimpleSwitch /comfyui/custom_nodes/ComfyUI-SimpleSwitch
RUN git clone https://github.com/kijai/ComfyUI-KJNodes /comfyui/custom_nodes/ComfyUI-KJNodes
RUN comfy node install --exit-on-fail comfyui-videohelpersuite
RUN git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation /comfyui/custom_nodes/ComfyUI-Frame-Interpolation
RUN git clone https://github.com/Smirnov75/ComfyUI-mxToolkit /comfyui/custom_nodes/ComfyUI-mxToolkit
RUN git clone https://github.com/boobkake22/ComfyUI-WanResolutions /comfyui/custom_nodes/ComfyUI-WanResolutions
RUN git clone https://github.com/boobkake22/ComfyUI-SamplingPlanner /comfyui/custom_nodes/ComfyUI-SamplingPlanner
RUN git clone https://github.com/Larryvrh/ComfyUI-MiniMax-H3-Turbo /comfyui/custom_nodes/ComfyUI-MiniMax-H3-Turbo
RUN git clone https://github.com/boobkake22/ComfyUI-YAWSettingsImporter /comfyui/custom_nodes/ComfyUI-YAWSettingsImporter

RUN git clone https://github.com/alexopus/ComfyUI-Image-Saver /comfyui/custom_nodes/ComfyUI-Image-Saver
RUN git clone https://github.com/JaredTherriault/ComfyUI-JNodes /comfyui/custom_nodes/ComfyUI-JNodes
RUN git clone https://github.com/ComfyAssets/ComfyUI_Selectors.git /comfyui/custom_nodes/ComfyUI_Selectors
RUN git clone https://github.com/mickmumpitz/ComfyUI-Mickmumpitz-Nodes /comfyui/custom_nodes/ComfyUI-Mickmumpitz-Nodes

COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
# Install custom-node dependencies into ComfyUI's runtime Python environment
RUN uv pip install --python /opt/venv/bin/python opencv-python-headless && \
    for r in /comfyui/custom_nodes/*/requirements.txt; do \
        if [ -f "$r" ]; then \
            uv pip install --python /opt/venv/bin/python -r "$r"; \
        fi; \
    done

# download models into comfyui
# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/example.png' "https://cool-anteater-319.convex.cloud/api/storage/40fb84bc-9797-477b-b6e8-1a19c2fe9295"

# list every custom node and show which ones fail to load (look for IMPORT FAILED in the build log)
RUN /opt/venv/bin/python /comfyui/main.py --cpu --quick-test-for-ci 2>&1 | tee /tmp/nodecheck.log
