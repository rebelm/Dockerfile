FROM debian:stretch-slim

RUN apt-get update  \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    fontconfig \
    git \
    gcc \
    iputils-ping \
    libevent-dev \
    libncurses-dev \
    locales \
    make \
    procps \
    wget \
    vim

ENV TMUX=2.7

RUN wget -O - https://github.com/tmux/tmux/releases/download/${TMUX}/tmux-${TMUX}.tar.gz | tar xzf - \
  && cd tmux-${TMUX} \
  && LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib" ./configure --prefix=/usr/local \
  && make \
  && make install \
  && cd .. \
  && rm -rf tmux-${TMUX} \
  && apt-get purge -y gcc make \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN groupadd tmuxuser && useradd --create-home --shell /bin/bash --gid tmuxuser tmuxuser
USER tmuxuser
WORKDIR /home/tmuxuser

RUN mkdir -p .fonts .config/fontconfig/conf.d \
  && wget -P .fonts https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf \
  && wget -P .config/fontconfig/conf.d/ https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf \
  && fc-cache -vf .fonts/

ENV TERM=xterm-256color

RUN mkdir dot
COPY --chown=tmuxuser:tmuxuser . dot
RUN dot/dot2.sh
