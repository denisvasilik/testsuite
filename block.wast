;; Test `block` operator

(module
  ;; Auxiliary definition
  (func $dummy)

  (func (export "empty")
    (block)
    (block $l)
  )

  (func (export "singular") (result i32)
    (block (nop))
    (block (result i32) (i32.const 7))
  )

  (func (export "multi") (result i32)
    (block (call $dummy) (call $dummy) (call $dummy) (call $dummy))
    (block (result i32) (call $dummy) (call $dummy) (call $dummy) (i32.const 8))
  )

  (func (export "nested") (result i32)
    (block (result i32)
      (block (call $dummy) (block) (nop))
      (block (result i32) (call $dummy) (i32.const 9))
    )
  )

  (func (export "deep") (result i32)
    (block (result i32) (block (result i32)
      (block (result i32) (block (result i32)
        (block (result i32) (block (result i32)
          (block (result i32) (block (result i32)
            (block (result i32) (block (result i32)
              (block (result i32) (block (result i32)
                (block (result i32) (block (result i32)
                  (block (result i32) (block (result i32)
                    (block (result i32) (block (result i32)
                      (block (result i32) (block (result i32)
                        (block (result i32) (block (result i32)
                          (block (result i32) (block (result i32)
                            (block (result i32) (block (result i32)
                              (block (result i32) (block (result i32)
                                (block (result i32) (block (result i32)
                                  (block (result i32) (block (result i32)
                                    (block (result i32) (block (result i32)
                                      (block (result i32) (block (result i32)
                                        (block (result i32) (block (result i32)
                                          (call $dummy) (i32.const 150)
                                        ))
                                      ))
                                    ))
                                  ))
                                ))
                              ))
                            ))
                          ))
                        ))
                      ))
                    ))
                  ))
                ))
              ))
            ))
          ))
        ))
      ))
    ))
  )

  (func (export "as-unary-operand") (result i32)
    (i32.ctz (block (result i32) (call $dummy) (i32.const 13)))
  )
  (func (export "as-binary-operand") (result i32)
    (i32.mul
      (block (result i32) (call $dummy) (i32.const 3))
      (block (result i32) (call $dummy) (i32.const 4))
    )
  )
  (func (export "as-test-operand") (result i32)
    (i32.eqz (block (result i32) (call $dummy) (i32.const 13)))
  )
  (func (export "as-compare-operand") (result i32)
    (f32.gt
      (block (result f32) (call $dummy) (f32.const 3))
      (block (result f32) (call $dummy) (f32.const 3))
    )
  )

  (func (export "break-bare") (result i32)
    (block (br 0) (unreachable))
    (block (br_if 0 (i32.const 1)) (unreachable))
    (block (br_table 0 (i32.const 0)) (unreachable))
    (block (br_table 0 0 0 (i32.const 1)) (unreachable))
    (i32.const 19)
  )
  (func (export "break-value") (result i32)
    (block (result i32) (br 0 (i32.const 18)) (i32.const 19))
  )
  (func (export "break-repeated") (result i32)
    (block (result i32)
      (br 0 (i32.const 18))
      (br 0 (i32.const 19))
      (drop (br_if 0 (i32.const 20) (i32.const 0)))
      (drop (br_if 0 (i32.const 20) (i32.const 1)))
      (br 0 (i32.const 21))
      (br_table 0 (i32.const 22) (i32.const 4))
      (br_table 0 0 0 (i32.const 23) (i32.const 1))
      (i32.const 21)
    )
  )
  (func (export "break-inner") (result i32)
    (local i32)
    (set_local 0 (i32.const 0))
    (set_local 0 (i32.add (get_local 0) (block (result i32) (block (result i32) (br 1 (i32.const 0x1))))))
    (set_local 0 (i32.add (get_local 0) (block (result i32) (block (br 0)) (i32.const 0x2))))
    (set_local 0
      (i32.add (get_local 0) (block (result i32) (i32.ctz (br 0 (i32.const 0x4)))))
    )
    (set_local 0
      (i32.add (get_local 0) (block (result i32) (i32.ctz (block (result i32) (br 1 (i32.const 0x8))))))
    )
    (get_local 0)
  )

  (func (export "effects") (result i32)
    (local i32)
    (block
      (set_local 0 (i32.const 1))
      (set_local 0 (i32.mul (get_local 0) (i32.const 3)))
      (set_local 0 (i32.sub (get_local 0) (i32.const 5)))
      (set_local 0 (i32.mul (get_local 0) (i32.const 7)))
      (br 0)
      (set_local 0 (i32.mul (get_local 0) (i32.const 100)))
    )
    (i32.eq (get_local 0) (i32.const -14))
  )
)

(assert_return (invoke "empty"))
(assert_return (invoke "singular") (i32.const 7))
(assert_return (invoke "multi") (i32.const 8))
(assert_return (invoke "nested") (i32.const 9))
(assert_return (invoke "deep") (i32.const 150))

(assert_return (invoke "as-unary-operand") (i32.const 0))
(assert_return (invoke "as-binary-operand") (i32.const 12))
(assert_return (invoke "as-test-operand") (i32.const 0))
(assert_return (invoke "as-compare-operand") (i32.const 0))

(assert_return (invoke "break-bare") (i32.const 19))
(assert_return (invoke "break-value") (i32.const 18))
(assert_return (invoke "break-repeated") (i32.const 18))
(assert_return (invoke "break-inner") (i32.const 0xf))

(assert_return (invoke "effects") (i32.const 1))

(assert_invalid
  (module (func $type-empty-i32 (result i32) (block)))
  "type mismatch"
)
(assert_invalid
  (module (func $type-empty-i64 (result i64) (block)))
  "type mismatch"
)
(assert_invalid
  (module (func $type-empty-f32 (result f32) (block)))
  "type mismatch"
)
(assert_invalid
  (module (func $type-empty-f64 (result f64) (block)))
  "type mismatch"
)

(assert_invalid
  (module (func $type-value-i32-vs-void
    (block (i32.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-i64-vs-void
    (block (i64.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-f32-vs-void
    (block (f32.const 1.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-f64-vs-void
    (block (f64.const 1.0))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-value-empty-vs-i32 (result i32)
    (block (result i32))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-empty-vs-i64 (result i64)
    (block (result i64))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-empty-vs-f32 (result f32)
    (block (result f32))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-empty-vs-f64 (result f64)
    (block (result f64))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-value-void-vs-i32 (result i32)
    (block (result i32) (nop))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-void-vs-i64 (result i64)
    (block (result i64) (nop))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-void-vs-f32 (result f32)
    (block (result f32) (nop))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-void-vs-f64 (result f64)
    (block (result f64) (nop))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-value-i32-vs-i64 (result i32)
    (block (result i32) (i64.const 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-i32-vs-f32 (result i32)
    (block (result i32) (f32.const 0.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-i32-vs-f64 (result i32)
    (block (result i32) (f64.const 0.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-i64-vs-i32 (result i64)
    (block (result i64) (i32.const 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-i64-vs-f32 (result i64)
    (block (result i64) (f32.const 0.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-i64-vs-f64 (result i64)
    (block (result i64) (f64.const 0.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-f32-vs-i32 (result f32)
    (block (result f32) (i32.const 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-f32-vs-i64 (result f32)
    (block (result f32) (i64.const 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-f32-vs-f64 (result f32)
    (block (result f32) (f64.const 0.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-f64-vs-i32 (result f64)
    (block (result f64) (i32.const 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-f64-vs-i64 (result f64)
    (block (result f64) (i64.const 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-f64-vs-f32 (result f32)
    (block (result f64) (f32.const 0.0))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-value-unreached-select-i32-i64 (result i32)
    (block (result i64) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-i32-f32 (result i32)
    (block (result f32) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-i32-f64 (result i32)
    (block (result f64) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-i64-i32 (result i64)
    (block (result i32) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-i64-f32 (result i64)
    (block (result f32) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-i64-f64 (result i64)
    (block (result f64) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-f32-i32 (result f32)
    (block (result i32) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-f32-i64 (result f32)
    (block (result i64) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-f32-f64 (result f32)
    (block (result f64) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-f64-i32 (result f64)
    (block (result i32) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-f64-i64 (result f64)
    (block (result i64) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-value-unreached-select-f64-f32 (result f64)
    (block (result f32) (select (unreachable) (unreachable) (unreachable)))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-last-void-vs-i32 (result i32)
    (block (result i32) (br 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-last-void-vs-i64 (result i64)
    (block (result i64) (br 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-last-void-vs-f32 (result f32)
    (block (result f32) (br 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-last-void-vs-f64 (result f64)
    (block (result f64) (br 0))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-empty-vs-i32 (result i32)
    (block (result i32) (br 0) (i32.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-empty-vs-i64 (result i64)
    (block (result i64) (br 0) (i64.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-empty-vs-f32 (result f32)
    (block (result f32) (br 0) (f32.const 1.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-empty-vs-f64 (result f64)
    (block (result f64) (br 0) (f64.const 1.0))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-void-vs-i32 (result i32)
    (block (result i32) (br 0 (nop)) (i32.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-void-vs-i64 (result i64)
    (block (result i64) (br 0 (nop)) (i64.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-void-vs-f32 (result f32)
    (block (result f32) (br 0 (nop)) (f32.const 1.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-void-vs-f64 (result f64)
    (block (result f64) (br 0 (nop)) (f64.const 1.0))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-i32-vs-i64 (result i32)
    (block (result i32) (br 0 (i64.const 1)) (i32.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-i32-vs-f32 (result i32)
    (block (result i32) (br 0 (f32.const 1.0)) (i32.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-i32-vs-f64 (result i32)
    (block (result i32) (br 0 (f64.const 1.0)) (i32.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-i64-vs-i32 (result i64)
    (block (result i64) (br 0 (i32.const 1)) (i64.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-i64-vs-f32 (result i64)
    (block (result i64) (br 0 (f32.const 1.0)) (i64.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-i64-vs-f64 (result i64)
    (block (result i64) (br 0 (f64.const 1.0)) (i64.const 1))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-f32-vs-i32 (result f32)
    (block (result f32) (br 0 (i32.const 1)) (f32.const 1.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-f32-vs-i64 (result f32)
    (block (result f32) (br 0 (i64.const 1)) (f32.const 1.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-f32-vs-f64 (result f32)
    (block (result f32) (br 0 (f64.const 1.0)) (f32.const 1.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-f64-vs-i32 (result f64)
    (block (result i64) (br 0 (i32.const 1)) (f64.const 1.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-f64-vs-i64 (result f64)
    (block (result f64) (br 0 (i64.const 1)) (f64.const 1.0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-f64-vs-f32 (result f64)
    (block (result f64) (br 0 (f32.const 1.0)) (f64.const 1))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-first-void-vs-i32 (result i32)
    (block (result i32) (br 0 (nop)) (br 0 (i32.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-void-vs-i64 (result i64)
    (block (result i64) (br 0 (nop)) (br 0 (i64.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-void-vs-f32 (result f32)
    (block (result f32) (br 0 (nop)) (br 0 (f32.const 1.0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-void-vs-f64 (result f64)
    (block (result f64) (br 0 (nop)) (br 0 (f64.const 1.0)))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-first-i32-vs-i64 (result i32)
    (block (result i32) (br 0 (i64.const 1)) (br 0 (i32.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-i32-vs-f32 (result i32)
    (block (result i32) (br 0 (f32.const 1.0)) (br 0 (i32.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-i32-vs-f64 (result i32)
    (block (result i32) (br 0 (f64.const 1.0)) (br 0 (i32.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-i64-vs-i32 (result i64)
    (block (result i64) (br 0 (i32.const 1)) (br 0 (i64.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-i64-vs-f32 (result i64)
    (block (result i64) (br 0 (f32.const 1.0)) (br 0 (i64.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-i64-vs-f64 (result i64)
    (block (result i64) (br 0 (f64.const 1.0)) (br 0 (i64.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-f32-vs-i32 (result f32)
    (block (result f32) (br 0 (i32.const 1)) (br 0 (f32.const 1.0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-f32-vs-i64 (result f32)
    (block (result f32) (br 0 (i64.const 1)) (br 0 (f32.const 1.0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-f32-vs-f64 (result f32)
    (block (result f32) (br 0 (f64.const 1.0)) (br 0 (f32.const 1.0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-f64-vs-i32 (result f64)
    (block (result f64) (br 0 (i32.const 1)) (br 0 (f64.const 1.0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-f64-vs-i64 (result f64)
    (block (result f64) (br 0 (i64.const 1)) (br 0 (f64.const 1.0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-first-f64-vs-f32 (result f64)
    (block (result f64) (br 0 (f32.const 1.0)) (br 0 (f64.const 1.0)))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-nested-i32-vs-void
    (block (result i32) (block (result i32) (br 1 (i32.const 1))) (br 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-i64-vs-void
    (block (result i64) (block (result i64) (br 1 (i64.const 1))) (br 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-f32-vs-void
    (block (result f32) (block (result f32) (br 1 (f32.const 1.0))) (br 0))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-f64-vs-void
    (block (result f64) (block (result f64) (br 1 (f64.const 1.0))) (br 0))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-nested-empty-vs-i32 (result i32)
    (block (result i32) (block (br 1)) (br 0 (i32.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-empty-vs-i64 (result i64)
    (block (result i64) (block (br 1)) (br 0 (i64.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-empty-vs-f32 (result f32)
    (block (result f32) (block (br 1)) (br 0 (f32.const 1.0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-empty-vs-f64 (result f64)
    (block (result f64) (block (br 1)) (br 0 (f64.const 1)))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-nested-void-vs-i32 (result i32)
    (block (result i32) (block (result i32) (br 1 (nop))) (br 0 (i32.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-void-vs-i64 (result i64)
    (block (result i64) (block (result i64) (br 1 (nop))) (br 0 (i64.const 1)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-void-vs-f32 (result f32)
    (block (result f32) (block (result f32) (br 1 (nop))) (br 0 (f32.const 1.0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-void-vs-f64 (result f64)
    (block (result f64) (block (result f64) (br 1 (nop))) (br 0 (f64.const 1.0)))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-nested-i32-vs-i64 (result i32)
    (block (result i32)
      (block (result i32) (br 1 (i64.const 1))) (br 0 (i32.const 1))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-i32-vs-f32 (result i32)
    (block (result i32)
      (block (result i32) (br 1 (f32.const 1.0))) (br 0 (i32.const 1))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-i32-vs-f64 (result i32)
    (block (result i32)
      (block (result i32) (br 1 (f64.const 1.0))) (br 0 (i32.const 1))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-i64-vs-i32 (result i64)
    (block (result i64)
      (block (result i64) (br 1 (i32.const 1))) (br 0 (i64.const 1))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-i64-vs-f32 (result i64)
    (block (result i64)
      (block (result i64) (br 1 (f32.const 1.0))) (br 0 (i64.const 1))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-i64-vs-f64 (result i64)
    (block (result i64)
      (block (result i64) (br 1 (f64.const 1.0))) (br 0 (i64.const 1))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-f32-vs-i32 (result f32)
    (block (result f32)
      (block (result f32) (br 1 (i32.const 1))) (br 0 (f32.const 1.0))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-f32-vs-i64 (result f32)
    (block (result f32)
      (block (result f32) (br 1 (i64.const 1))) (br 0 (f32.const 1.0))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-f32-vs-f64 (result f32)
    (block (result f32)
      (block (result f32) (br 1 (f64.const 1.0))) (br 0 (f32.const 1.0))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-f64-vs-i32 (result f64)
    (block (result f64)
      (block (result f64) (br 1 (i32.const 1))) (br 0 (f64.const 1.0))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-f64-vs-i64 (result f64)
    (block (result f64)
      (block (result f64) (br 1 (i64.const 1))) (br 0 (f64.const 1.0))
    )
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-nested-f64-vs-f32 (result f64)
    (block (result f64)
      (block (result f64) (br 1 (f32.const 1.0))) (br 0 (f64.const 1.0))
    )
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-operand-empty-vs-i32 (result i32)
    (i32.ctz (block (br 0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-empty-vs-i64 (result i64)
    (i64.ctz (block (br 0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-empty-vs-f32 (result f32)
    (f32.floor (block (br 0)))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-empty-vs-f64 (result f64)
    (f64.floor (block (br 0)))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-operand-void-vs-i32 (result i32)
    (i32.ctz (block (br 0 (nop))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-void-vs-i64 (result i64)
    (i64.ctz (block (br 0 (nop))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-void-vs-f32 (result f32)
    (f32.floor (block (br 0 (nop))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-void-vs-f64 (result f64)
    (f64.floor (block (br 0 (nop))))
  ))
  "type mismatch"
)

(assert_invalid
  (module (func $type-break-operand-i32-vs-i64 (result i32)
    (i64.ctz (block (br 0 (i64.const 9))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-i32-vs-f32 (result i32)
    (f32.floor (block (br 0 (f32.const 9.0))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-i32-vs-f64 (result i32)
    (f64.floor (block (br 0 (f64.const 9.0))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-i64-vs-i32 (result i64)
    (i32.ctz (block (br 0 (i32.const 9))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-i64-vs-f32 (result i64)
    (f32.floor (block (br 0 (f32.const 9.0))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-i64-vs-f64 (result i64)
    (f64.floor (block (br 0 (f64.const 9.0))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-f32-vs-i32 (result f32)
    (i32.ctz (block (br 0 (i32.const 9))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-f32-vs-i64 (result f32)
    (i64.ctz (block (br 0 (i64.const 9))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-f32-vs-f64 (result f32)
    (f64.floor (block (br 0 (f64.const 9.0))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-f64-vs-i32 (result f64)
    (i32.ctz (block (br 0 (i32.const 9))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-f64-vs-i64 (result f64)
    (i64.ctz (block (br 0 (i64.const 9))))
  ))
  "type mismatch"
)
(assert_invalid
  (module (func $type-break-operand-f64-vs-f32 (result f64)
    (f32.floor (block (br 0 (f32.const 9.0))))
  ))
  "type mismatch"
)

(assert_malformed
  (module quote "(func block end $l)")
  "mismatching label"
)
(assert_malformed
  (module quote "(func block $a end $l)")
  "mismatching label"
)
