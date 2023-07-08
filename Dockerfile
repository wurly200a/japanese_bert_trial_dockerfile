FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

ARG NB_USER="wurly"
ARG NB_UID="1000"
ARG NB_GID="100"
ENV HOME=/home/$NB_USER
RUN pip install transformers pyknp fugashi ipadic

USER root
ADD fix-permissions /usr/local/bin/fix-permissions

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN chmod a+rx /usr/local/bin/fix-permissions && \
    chmod g+w /etc/passwd && \
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc  && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER  && \
    fix-permissions /home/$NB_USER && \
    apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential cmake libboost-all-dev google-perftools libgoogle-perftools-dev wget unzip

USER root
RUN pip install jupyter notebook && \
    jupyter notebook --generate-config

EXPOSE 8888

RUN mkdir /etc/jupyter/ && fix-permissions /etc/jupyter/
COPY jupyter_notebook_config.py /etc/jupyter/
RUN chmod 777 -R /home/$NB_USER/.jupyter/

USER $NB_USER

WORKDIR /home/$NB_USER
CMD /opt/conda/bin/jupyter notebook
