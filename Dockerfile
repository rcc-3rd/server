FROM ruby:2.3

# locale
RUN apt update
RUN apt install -y locales \
  && locale-gen ja_JP.UTF-8 \
  && localedef -f UTF-8 -i ja_JP ja_JP.utf8
ENV LANG ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8

EXPOSE 8080

ENTRYPOINT ["/bin/bash"]

