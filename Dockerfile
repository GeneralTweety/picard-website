FROM python:2.7.13

ARG BUILD_DEPS=" \
    build-essential \
    git \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev"

RUN apt-get update && \
    apt-get install \
        --no-install-suggests \
        --no-install-recommends \
        -y \
        $BUILD_DEPS && \
    rm -rf /var/lib/apt/lists/*

# Node
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

WORKDIR /code/website

# Python dependencies
RUN pip install uWSGI==2.0.13.1
COPY ./requirements.txt /code/website
RUN pip install -r requirements.txt

# Node dependencies
COPY ./package.json /code/website
RUN npm install

COPY . /code/website

# Translations
RUN pybabel compile -d website/frontend/translations

# Static files
RUN ./node_modules/.bin/gulp

# Plugins
RUN fab plugins_generate

RUN apt-get purge -y $BUILD_DEPS && \
    apt-get autoremove -y

COPY ./docker/uwsgi.ini /etc/uwsgi/uwsgi.ini
EXPOSE 3031
CMD ["uwsgi", "/etc/uwsgi/uwsgi.ini"]
