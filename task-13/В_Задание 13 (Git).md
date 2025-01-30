Залить репозиторий на github.
```
[~]$ mkdir test-repo
[~]$ cd test-repo/
[test-repo]$ git init

[test-repo]$ gh repo create

[test-repo]$ echo "master 1 file" > file1.txt
[test-repo]$ git add -A
[test-repo]$ git commit -m "init"

[test-repo]$ git push -u origin master
```

Создать ветку develop, внести изменение в файлы в develop и сделать pull request (merge request) в master (main).
```
[test-repo]$ git branch dev
[test-repo]$ git checkout dev
Switched to branch 'dev'

[test-repo]$ ls
file1.txt

[test-repo]$ echo "dev1" > file2.txt
[test-repo]$ git add -A
[test-repo]$ git status
On branch dev
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   file2.txt
[test-repo]$ git commit -m "dev1.txt added"
[test-repo]$ git push -u origin dev

[test-repo]$ gh pr new
...
https://github.com/Patronogenesys/test-repo/pull/1
```

Показать откат коммита в develop ветке и сделать pull request (merge request).
```
[test-repo]$ git fetch

[test-repo]$ git revert HEAD
[test-repo]$ git push
[test-repo]$ gh pr new
```

Создать 5 коммитов в develop ветке. В ветку main (master) записать только 1-й, 3-й и 
5-й коммиты, которые были сделаны в develop
```
[test-repo]$ git checkout dev
Your branch is up to date with 'origin/dev'.

[test-repo]$ echo "change 1" > file 1 && git add -A && 
[test-repo]$ echo "change 2" > file && git add -A && 
[test-repo]$ echo "change 3" >> file && git add -A && 
[test-repo]$ echo "change 4" >> file && git add -A && 
[test-repo]$ echo "change 5" >> file && git add -A && 

[test-repo]$ git checkout master 
Your branch is up to date with 'origin/master'.

[test-repo]$ git checkout -b cherrypick/dev
Switched to a new branch 'cherrypick/dev'

[test-repo]$ git log dev --oneline | tee /dev/null
6048c4a change 5
cbcfb92 change 4
b3c6b2b change 3
b7dfb91 change 2
1f56829 change 1
cacb72b Revert "dev1.txt added"
8450288 dev1.txt added
e1811bc init

[test-repo]$ git cherry-pick 1f56829 b3c6b2b 6048c4a
...
Разрешаем все конфликты
...

[test-repo]$ gh pr new

```