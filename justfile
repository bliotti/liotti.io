set positional-arguments

fmt:
  prettier --write .

serve:
  GIT_SHA=`git rev-parse HEAD` env=dev zola serve
