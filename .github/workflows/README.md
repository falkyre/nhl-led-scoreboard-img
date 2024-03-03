To trigger a workflow:
(I'm old and forget things)

example:

git commit -a -m "Update ansible playbook"
git push
git tag -a v1.6.12 -m "First release of the image based on latest raspian OS Bullseye. NOTE: The NHL API is currently being changed by the NHL so there is no guarentee that things will work properly."
git push origin v1.6.12