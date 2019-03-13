#!/bin/sh
cd signer

gunicorn --bind="0.0.0.0:5000" app:api