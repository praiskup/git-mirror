TESTS = \
	test-ff \
	test-merge \
	test-no-user

.PHONY: $(TESTS)

check: $(TESTS)

$(TESTS):
	@set -e ; \
	if /bin/bash -x ./tests/$@ 2>$@.log >$@.log; then \
	    echo "OK   $@" ; \
	else \
	    exit_status=$$? ; \
	    case $$exit_status in \
	        77) echo "SKIP $@" ;; \
	        *)  echo "FAIL $@" ; cat $@.log ; exit 1 ;; \
	    esac ; \
	fi ; \
	rm $@.log
