package authz

default allow := false

allow if input.body.userId == input.headers["x-user-claims"].userId