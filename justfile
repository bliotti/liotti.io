set positional-arguments

fmt:
  prettier --write .

serve:
  env=`git rev-parse HEAD` zola serve
