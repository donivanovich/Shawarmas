USE shawarmas;

CREATE TABLE IF NOT EXISTS producto_variantes (
    id_variante INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fk_producto INT UNSIGNED NOT NULL,
    fk_talla INT UNSIGNED NOT NULL,
    fk_color INT UNSIGNED NOT NULL,
    stock INT UNSIGNED NOT NULL DEFAULT 0,
    UNIQUE KEY uq_producto_talla_color (fk_producto, fk_talla, fk_color),
    CONSTRAINT fk_variantes_producto FOREIGN KEY (fk_producto) REFERENCES productos(id_producto) ON DELETE CASCADE,
    CONSTRAINT fk_variantes_talla FOREIGN KEY (fk_talla) REFERENCES tallas(id_talla),
    CONSTRAINT fk_variantes_color FOREIGN KEY (fk_color) REFERENCES colores(id_color)
) ENGINE = InnoDB;

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, stock)
SELECT p.id_producto, p.fk_talla, p.fk_color, p.stock
FROM productos p
LEFT JOIN producto_variantes v
    ON v.fk_producto = p.id_producto
    AND v.fk_talla = p.fk_talla
    AND v.fk_color = p.fk_color
WHERE v.id_variante IS NULL;

ALTER TABLE productos_pedidos
    ADD COLUMN fk_variante INT UNSIGNED NULL AFTER id_producto_pedido;

UPDATE productos_pedidos pp
INNER JOIN productos p ON p.id_producto = pp.fk_producto
INNER JOIN producto_variantes v
    ON v.fk_producto = p.id_producto
    AND v.fk_talla = pp.fk_talla
    AND v.fk_color = p.fk_color
SET pp.fk_variante = v.id_variante
WHERE pp.fk_variante IS NULL;

ALTER TABLE productos_pedidos
    DROP FOREIGN KEY fk_productos_pedidos_producto,
    DROP FOREIGN KEY fk_productos_pedidos_talla,
    DROP INDEX uq_producto_talla_pedido,
    MODIFY fk_producto INT UNSIGNED NULL,
    MODIFY fk_talla INT UNSIGNED NULL,
    MODIFY fk_variante INT UNSIGNED NOT NULL,
    ADD UNIQUE KEY uq_variante_pedido (fk_variante, fk_pedido),
    ADD CONSTRAINT fk_productos_pedidos_variante
        FOREIGN KEY (fk_variante) REFERENCES producto_variantes(id_variante);
