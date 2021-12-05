our_git ()
{
    git -c user.name="Some User" \
        -c user.email="some@example.com" \
        "$@"
}

repo_simple ()
{
    our_git init --bare origin.git
    our_git clone origin.git source

    (
        cd source || exit 1
        echo README > README
        our_git add README
        our_git commit -m "initial commit"

        our_git branch new_branch
        our_git checkout new_branch
        echo new_branch > new_branch
        our_git add new_branch
        our_git commit "new_branch" -m "new branch commit"
        git push --all --set-upstream origin
    )
}

repos_mirrored ()
{
    repo_simple source
    our_git clone --bare origin fork.git
}

repos_ff_ready ()
{
    repos_mirrored
    (
        cd source || exit 1

        our_git checkout main

        echo second commit >> README
        our_git add README
        our_git commit -m "second main commit"

        our_git checkout new_branch
        echo third commit >> new_branch
        our_git add new_branch
        our_git commit -m "third commit in new_branch"

        our_git push --all
    )
}

test_cleanup ()
{
    exit_status=$?
    case $__test_dir in
        /tmp/*)
            rm -rf "$__test_dir"
            ;;
    esac
    exit $exit_status
}

test_start ()
{
    set -e
    if test -x "$(pwd)/git-mirror"; then
        PATH="$(pwd):$PATH"
    elif test -x "$(pwd)/../git-mirror"; then
        PATH="$(pwd)/..:$PATH"
    else
        false
    fi
    __test_dir=$(mktemp -d "/tmp/testing-git-sync-XXXXXXX")
    cd "$__test_dir" || exit 1
    trap test_cleanup EXIT

}

# assert_log_length dir branch count
# ----------------------------------
assert_log_length ()
(
    cd "$1" || exit 1
    count=$(git log --format="%h" "$2" | wc -l)
    test "$count" -eq "$3" || exit 1
)
