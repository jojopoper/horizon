package db

import (
	"database/sql"
	"fmt"
	"log"
	"reflect"

	"github.com/jojopoper/horizon/test"
	"golang.org/x/net/context"
)

// OrderComparator is a func to compare two arbitrary values, used by the
// ShouldBeOrdered assertion
type OrderComparator func(idx int, l interface{}, r interface{}) string

func OpenTestDatabase() *sql.DB {

	result, err := sql.Open("postgres", test.DatabaseUrl())

	if err != nil {
		log.Panic(err)
	}
	return result
}

func OpenStellarCoreTestDatabase() *sql.DB {

	result, err := sql.Open("postgres", test.StellarCoreDatabaseUrl())

	if err != nil {
		log.Panic(err)
	}
	return result
}

func ShouldBeOrdered(actual interface{}, options ...interface{}) string {
	rv := reflect.ValueOf(actual)
	if rv.Len() == 0 {
		return "slice is empty"
	}

	if rv.Len() == 1 {
		return "slice has only one element"
	}

	t := options[0].(OrderComparator)

	prev := rv.Index(0).Interface()

	for i := 1; i < rv.Len(); i++ {
		cur := rv.Index(i).Interface()

		msg := t(i, prev, cur)

		if msg != "" {
			return msg
		}

		prev = cur
	}

	return ""
}

func ShouldBeOrderedAscending(actual interface{}, options ...interface{}) string {
	t := options[0].(func(interface{}) int64)

	var cmp OrderComparator = func(idx int, l interface{}, r interface{}) string {
		lnum := t(l)
		rnum := t(r)

		if lnum > rnum {
			return fmt.Sprintf(
				"not ordered ascending: idx:%s has order %d, which is less than the previous:%d",
				idx,
				rnum,
				lnum)
		}

		return ""
	}

	return ShouldBeOrdered(actual, cmp)
}

func ShouldBeOrderedDescending(actual interface{}, options ...interface{}) string {
	t := options[0].(func(interface{}) int64)

	var cmp OrderComparator = func(idx int, l interface{}, r interface{}) string {
		lnum := t(l)
		rnum := t(r)

		if lnum < rnum {
			return fmt.Sprintf(
				"not ordered descending: idx:%d has order %d, which is more than the previous:%d",
				idx,
				rnum,
				lnum)
		}

		return ""
	}

	return ShouldBeOrdered(actual, cmp)
}

// Mock Dump Query

type mockDumpQuery struct{}

func (q mockDumpQuery) Get(ctx context.Context) ([]interface{}, error) {
	return []interface{}{
		"hello",
		"world",
		"from",
		"go",
	}, nil
}

// Mock Query

type mockQuery struct {
	resultCount int
}

type mockResult struct {
	index int
}

func (q mockQuery) Select(ctx context.Context, dest interface{}) error {
	results := make([]mockResult, q.resultCount)

	for i := 0; i < q.resultCount; i++ {
		results[i] = mockResult{i}
	}

	return setOn(results, dest)
}

// BrokenQuery is a helper for tests that always returns an error
type BrokenQuery struct {
	Err error
}

func (q BrokenQuery) Select(ctx context.Context, dest interface{}) error {
	return q.Err
}
