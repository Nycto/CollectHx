package collect;

/**
 * Compares two values. Returns < 1 if the first is greatter than the second, 0
 * if they are equal, and > 1 if the second is greater than the first.
 */
typedef Compare<T> = T -> T -> Int;

/**
 * A red/black binary search tree
 */
class RedBlackTree<T> {

    /** The root node of the tree */
    private var root: Null<Node<T>> = null;

    /** The function used for comparing two nodes */
    private var compare: Compare<T>;

    /** Constructor */
    public function new ( compare: Compare<T> ) {
        this.compare = compare;
    }

    /** Handles an insert of case 5 */
    private function balanceAfterInsert5 ( node: Node<T> ): Void {
        node.parent.color = Black;
        node.grandparent().color = Red;
        if ( node.isLeftChild() ) {
            root = node.parent.rotateRight(root);
        }
        else {
            root = node.parent.rotateLeft(root);
        }
    }

    /** Handles an insert of case 4 */
    private function balanceAfterInsert4 ( node: Node<T> ): Void {
        if ( node.isRightChild() && node.parent.isLeftChild() ) {
            root = node.rotateLeft(root);
            balanceAfterInsert5( node.left );
        }
        else if ( node.isLeftChild() && node.parent.isRightChild() ) {
            root = node.rotateRight(root);
            balanceAfterInsert5( node.right );
        }
    }

    /** Handles an insert of case 3 */
    private function balanceAfterInsert3 ( node: Node<T> ): Void {
        var uncle = node.uncle();
        if ( uncle != null && uncle.color == Red ) {
            node.parent.color = Black;
            uncle.color = Black;
            var grandparent = node.grandparent();
            grandparent.color = Red;
            balanceAfterInsert1(grandparent);
        } else {
            balanceAfterInsert4(node);
        }
    }

    /** Handles an insert of case 2 */
    private function balanceAfterInsert2 ( node: Node<T> ): Void {
        if ( node.parent.color == Black ) {
            // Tree is still valid
            return;
        }
        else {
            balanceAfterInsert3(node);
        }
    }

    /** Balances a newly inserted node */
    private function balanceAfterInsert1 ( node: Node<T> ): Void {
        if ( node.parent == null ) {
            node.color = Black;
        }
        else {
            balanceAfterInsert2(node);
        }
    }

    /** Inserts a new node */
    public function insert ( value: T ): Void {
        if ( root == null ) {
            root = new Node( value );
            balanceAfterInsert1(root);
        }
        else {
            balanceAfterInsert1( root.insert(compare, value) );
        }
    }

    /** Converts this node to a string */
    public function toString(): String {
        return root == null ? "RedBlackTree()" : "RedBlackTree" + root;
    }

    /** Generates an iterator */
    public inline function iterator(): Iterator<T> {
        return new RedBlackIterator<T>(root == null ? null : root.leftmost());
    }

    /** Returns the minimum value */
    public inline function min(): Null<T> {
        return root == null ? null : root.leftmost().value;
    }

    /** Returns the maximum value */
    public inline function max(): Null<T> {
        return root == null ? null : root.rightmost().value;
    }
}

/** The color of a node */
enum RedOrBlack {
    Red;
    Black;
}

/** A node within the tree */
class Node<T> {

    /** The color of this node */
    public var color: RedOrBlack = Red;

    /** The parent of this node */
    public var parent: Null<Node<T>>;

    /** The left child of this node */
    public var left: Null<Node<T>> = null;

    /** The right child of this node */
    public var right: Null<Node<T>> = null;

    /** The value held by this node */
    public var value(default, null): T;

    /** Constructor */
    @:allow(collect.RedBlackTree)
    @:allow(RedBlackTreeTest)
    private function new ( value: T, parent: Null<Node<T>> = null ) {
        this.value = value;
        this.parent = parent;
    }

    /** Returns the grandparent of this node */
    public inline function grandparent(): Null<Node<T>> {
        return parent == null ? null : parent.parent;
    }

    /** Returns the uncle of this node */
    public inline function uncle(): Null<Node<T>> {
        var grandparent = grandparent();
        if ( grandparent == null ) {
            return null;
        }
        else if ( grandparent.left == parent ) {
            return grandparent.right;
        }
        else {
            return grandparent.left;
        }
    }

    /** Does a basic binary search tree insert */
    public inline function insert (compare: Compare<T>, newValue: T): Node<T> {
        var compared = compare(newValue, value);
        if ( compared <= 0 ) {
            if ( left == null ) {
                left = new Node<T>( newValue, this );
                return left;
            }
            else {
                return left.insert(compare, newValue);
            }
        }
        else {
            if ( right == null ) {
                right = new Node<T>( newValue, this );
                return right;
            }
            else {
                return right.insert(compare, newValue);
            }
        }
    }

    /** Walks every left-ward child down to the bottom */
    public inline function leftmost(): Node<T> {
        var leftward = this;
        while ( leftward.left != null ) {
            leftward = leftward.left;
        }
        return leftward;
    }

    /** Walks every rightward-ward child down to the bottom */
    public inline function rightmost(): Node<T> {
        var rightward = this;
        while ( rightward.right != null ) {
            rightward = rightward.right;
        }
        return rightward;
    }

    /** Whether this node is the right child of its parent */
    public inline function isRightChild(): Bool {
        return parent != null && parent.right == this;
    }

    /** Whether this node is the left child of its parent */
    public inline function isLeftChild(): Bool {
        return parent != null && parent.left == this;
    }

    /** Converts this node to a string */
    public function toString(): String {
        return "("
            + (color == Red ? "R" : "B") + ":"
            + value
            + (left != null || right != null ? " " + left + " " + right : "")
            + ")";
    }

    /** Rotates a node to the left, returns the root node */
    public inline function rotateLeft ( root: Node<T> ): Node<T> {
        var parent = this.parent;
        if ( parent == null ) {
            return root;
        }

        var grandparent = parent.parent;
        var child = this.left;

        // Move the child over
        parent.right = child;
        if ( child != null ) {
            child.parent = parent;
        }

        // Move the parent around
        this.left = parent;
        parent.parent = this;

        // Move the node itself
        this.parent = grandparent;

        // Update the grandparent, which may mean there is a new root
        if ( grandparent == null ) {
            return this;
        }
        else if ( grandparent.left == parent ) {
            grandparent.left = this;
            return root;
        }
        else {
            grandparent.right = this;
            return root;
        }
    }

    /** Rotates a node to the right, returns the new root node */
    public inline function rotateRight ( root: Node<T> ): Node<T> {
        var parent = this.parent;
        if ( parent == null ) {
            return root;
        }

        var grandparent = parent.parent;
        var child = this.right;

        // Move the child over
        parent.left = child;
        if ( child != null ) {
            child.parent = parent;
        }

        // Move the parent around
        this.right = parent;
        parent.parent = this;

        // Move the node itself
        this.parent = grandparent;

        // Update the grandparent, which may mean there is a new root
        if ( grandparent == null ) {
            return this;
        }
        else if ( grandparent.left == parent ) {
            grandparent.left = this;
            return root;
        }
        else {
            grandparent.right = this;
            return root;
        }
    }
}

/** A red/black tree iterator */
private class RedBlackIterator<T> {

    /** The next node */
    private var nextNode: Null<Node<T>>;

    /** Constructor */
    public function new ( next: Null<Node<T>> ) {
        this.nextNode = next;
    }

    /** Returns whether there are values left in this iterator */
    public inline function hasNext(): Bool {
        return nextNode != null;
    }

    /** Returns the next value in this iterator */
    public function next(): T {
        var current = nextNode;

        if ( current == null ) {
            return null;
        }
        else if ( current.right != null ) {
            nextNode = current.right.leftmost();
        }
        else {
            while ( nextNode.isRightChild() ) {
                nextNode = nextNode.parent;
            }
            nextNode = nextNode.parent;
        }

        return current.value;
    }
}

