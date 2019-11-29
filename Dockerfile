FROM python:3.6
RUN mkdir /prediction
WORKDIR /prediction
COPY ./requirements.txt /prediction/requirements.txt
RUN mkdir /prediction/web
COPY ./resources/web /prediction/web
RUN pip3 install -r /prediction/requirements.txt
ENV PROJECT_HOME=/prediction
RUN ls /prediction/web
CMD [ "python3", "/prediction/web/predict_flask.py" ]