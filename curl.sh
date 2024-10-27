#!/bin/bash
JWT_TOKEN="eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiNDk4M2MyNjctNjU5OS00NGYxLThmZDMtYWQ2NmQ5MGJhYTQ3IiwiZW1haWwiOiJjaGlib2d1Y2hpc29tdUBnbWFpbC5jb20iLCJleHAiOjE3MzAxMjAyNTF9.VnqbN8ePLoHPlIdhuX23iJw06IUvLYWCmjIgQaD6qHU"

curl -X GET http://localhost:3000/api/v1/spaces \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -H "Authorization: Bearer $JWT_TOKEN"