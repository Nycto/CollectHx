package;

import collect.RedBlackTree;
import massive.munit.Assert;

class RedBlackTreeTest {

    private static function equals ( a: Int, b: Int ) {
        return a == b;
    }

    private static function compare( a: Int, b: Int ) {
        return a == b ? 0 : ( a < b ? -1 : 1 );
    }

    private static function node(
        value: Int, left: Null<Node<Int>> = null, right: Null<Node<Int>> = null
    ) {
        var node = new Node(value);
        if ( left != null ) {
            node.left = left;
            left.parent = node;
        }
        if ( right != null ) {
            node.right = right;
            right.parent = node;
        }
        return node;
    }

    private static function validateStructure(
        node: Node<Int>,
        parent: Null<Node<Int>> = null
    ) {
        if ( node.parent != parent ) {
            Assert.fail("Invalid tree");
        }

        if ( node.left != null ) {
            validateStructure(node.left, node);
        }

        if ( node.right != null ) {
            validateStructure(node.right, node);
        }
    }

    @Test public function testInsertAndIteration():Void {
        var tree = new RedBlackTree<Int>(compare);
        Helper.arrayEqualsUsing(
            [], Helper.toArray( tree.iterator() ), equals );

        tree.insert(1);
        Helper.arrayEqualsUsing(
            [1], Helper.toArray( tree.iterator() ), equals );

        tree.insert(3);
        Helper.arrayEqualsUsing(
            [1, 3], Helper.toArray( tree.iterator() ), equals );

        tree.insert(2);
        Helper.arrayEqualsUsing(
            [1, 2, 3], Helper.toArray( tree.iterator() ), equals );

        tree.insert(4);
        Helper.arrayEqualsUsing(
            [1, 2, 3, 4], Helper.toArray( tree.iterator() ), equals );

        tree.insert(6);
        Helper.arrayEqualsUsing(
            [1, 2, 3, 4, 6], Helper.toArray( tree.iterator() ), equals );

        tree.insert(5);
        Helper.arrayEqualsUsing(
            [1, 2, 3, 4, 5, 6], Helper.toArray( tree.iterator() ), equals );
    }

    @Test public function testInsertDuplicates():Void {
        var tree = new RedBlackTree<Int>(compare);

        tree.insert(1);
        tree.insert(3);
        tree.insert(3);
        tree.insert(4);
        tree.insert(3);
        tree.insert(2);

        Helper.arrayEqualsUsing(
            [1, 2, 3, 3, 3, 4], Helper.toArray( tree.iterator() ), equals );
    }

    @Test public function testMinMax():Void {
        var tree = new RedBlackTree<Int>(compare);
        Assert.isNull( tree.min() );
        Assert.isNull( tree.max() );

        tree.insert(1);
        Assert.areEqual( 1, tree.min() );
        Assert.areEqual( 1, tree.max() );

        tree.insert(2);
        Assert.areEqual( 1, tree.min() );
        Assert.areEqual( 2, tree.max() );

        tree.insert(0);
        Assert.areEqual( 0, tree.min() );
        Assert.areEqual( 2, tree.max() );
    }

    @Test public function testRotate_rootChange():Void {
        var pivot = node(3, node(2), node(4));
        var root = node(1, node(0), pivot);

        Assert.areEqual(pivot, pivot.rotateLeft(root));
        validateStructure(pivot);
        Assert.areEqual(
            "(R:3 (R:1 (R:0) (R:2)) (R:4))",
            pivot.toString()
        );

        Assert.areEqual(root, root.rotateRight(pivot));
        validateStructure(root);
        Assert.areEqual(
            "(R:1 (R:0) (R:3 (R:2) (R:4)))",
            root.toString()
        );
    }

    @Test public function testRotate_noRootChange():Void {
        var pivot = node(3, node(2), node(4));
        var parent = node(1, node(0), pivot);
        var root = node(100, parent);

        Assert.areEqual(root, pivot.rotateLeft(root));
        validateStructure(root);
        Assert.areEqual(
            "(R:100 (R:3 (R:1 (R:0) (R:2)) (R:4)) null)",
            root.toString()
        );

        Assert.areEqual(root, parent.rotateRight(root));
        validateStructure(root);
        Assert.areEqual(
            "(R:100 (R:1 (R:0) (R:3 (R:2) (R:4))) null)",
            root.toString()
        );
    }

    @Test public function testRotate_noChildren():Void {
        var pivot = node(3);
        var parent = node(2, null, pivot);
        var root = node(1, parent, null);

        Assert.areEqual(root, pivot.rotateLeft(root));
        validateStructure(root);
        Assert.areEqual(
            "(R:1 (R:3 (R:2) null) null)",
            root.toString()
        );

        Assert.areEqual(root, parent.rotateRight(root));
        validateStructure(root);
        Assert.areEqual(
            "(R:1 (R:2 null (R:3)) null)",
            root.toString()
        );
    }

    @Test public function testRotate_root():Void {
        var root = node(2, node(1), node(3));

        Assert.areEqual(root, root.rotateLeft(root));
        validateStructure(root);
        Assert.areEqual( "(R:2 (R:1) (R:3))", root.toString() );

        Assert.areEqual(root, root.rotateRight(root));
        validateStructure(root);
        Assert.areEqual( "(R:2 (R:1) (R:3))", root.toString() );
    }

    @Test public function testInsertCase1():Void {
        var tree = new RedBlackTree<Int>(compare);
        tree.insert(1);
        Assert.areEqual("RedBlackTree(B:1)", tree.toString());
    }

    @Test public function testInsertCase2():Void {
        var tree = new RedBlackTree<Int>(compare);
        tree.insert(2);
        tree.insert(1);
        tree.insert(3);
        Assert.areEqual(
            "RedBlackTree(B:2 (R:1) (R:3))",
            tree.toString()
        );
    }

    @Test public function testInsertCase3():Void {
        var tree = new RedBlackTree<Int>(compare);
        tree.insert(2);
        tree.insert(3);
        tree.insert(1);
        tree.insert(0);
        Assert.areEqual(
            "RedBlackTree(B:2 (B:1 (R:0) null) (B:3))",
            tree.toString()
        );
    }

    @Test public function testInsertCase5_left():Void {
        var tree = new RedBlackTree<Int>(compare);
        tree.insert(3);
        tree.insert(1);
        tree.insert(2);
        Assert.areEqual(
            "RedBlackTree(B:2 (R:1) (R:3))",
            tree.toString()
        );
    }

    @Test public function testInsertCase5_right():Void {
        var tree = new RedBlackTree<Int>(compare);
        tree.insert(1);
        tree.insert(3);
        tree.insert(2);
        Assert.areEqual(
            "RedBlackTree(B:2 (R:1) (R:3))",
            tree.toString()
        );
    }
}


