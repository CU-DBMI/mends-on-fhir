FROM jupyter/minimal-notebook
USER 0

# Adds Docker and RISE to JupyterLab
# JDR = jupyter-docker-rise

# From https://docs.docker.com/engine/install/ubuntu/
# Step 3: https://devopscube.com/run-docker-in-docker/ How to run docker in docker container [3 easy methods]
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
   sh get-docker.sh 

# From https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html#slideshows-with-jupyterlab-and-rise
RUN mamba install --yes 'jupyterlab_rise' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

COPY ./start_jdr.sh /

CMD ["/start_jdr.sh"]
