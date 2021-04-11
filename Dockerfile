FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

RUN apt-get update -y

RUN apt-get install -y git make build-essential libssl-dev \
  zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl \
  llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv

RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile

ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN echo $PATH
RUN env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.6.7
RUN pyenv global 3.6.7
RUN pyenv rehash

COPY ./requirements.txt /var/constrained-r-cnn/requirements.txt
WORKDIR /var/constrained-r-cnn

RUN pip install -r requirements.txt
RUN pip install ipython jupyterlab

CMD ["ipython", "notebook", "--allow-root", "--ip", "0.0.0.0"]
