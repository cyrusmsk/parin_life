import parin;

float fps = 0.0f;

float remEuclid(float x, float y) {
    return x - floor(x / y) * y;
}

Vec2 rand2() {
    return Vec2(randf(), randf());
}

struct Boid {
    Vec2 pos;
    Vec2 vel;
}

struct Game {
    List!Boid boids;
    float reach;
    Vec2 size;
    float speed;

    static Game gameInit(size_t boidCount) {
        auto size = windowSize();
        auto sizeMax = max(size.x, size.y);
        auto game = Game(
            List!Boid(),
            0.05 * sizeMax,
            size,
            0.1 * sizeMax
        );

        foreach (i; 0 .. boidCount)
            game.addBoid();
        return game;
    }

    void addBoid() {
        this.boids.push(Boid(
                rand2() * this.size,
                (rand2() - Vec2(0.5)).normalize()
        ));
    }

    Vec2 delta(Vec2 toward, Vec2 from) {
        auto size = this.size;
        auto half = size / 2.0f;
        Vec2 delta = toward - from;
        // Wrap delta
        if (delta.x < -half.x)
            delta.x += size.x;
        else if (delta.x > half.x)
            delta.x -= size.x;
        if (delta.y < -half.y)
            delta.y += size.y;
        else if (delta.y > half.y)
            delta.y -= size.y;
        return delta;
    }

    void draw(Rgba color) {
        foreach (boid; this.boids.items) {
            immutable pos = boid.pos - 1.0f;
            drawRect(Rect(pos.x, pos.y, 3.0f, 3.0f), color);
        }
    }

    void update(float dt) {
        immutable speed = this.speed;
        foreach (ref boid; this.boids.items) {
            updateBoidVel(boid);
            boid.pos = wrap(boid.pos + boid.vel * speed * dt);
        }
    }

    void updateBoidVel(ref Boid boid) {
        immutable reach = this.reach;
        auto meanDelta = Vec2(0.0f);
        auto meanTrend = Vec2(0.0f);
        auto meanSpread = Vec2(0.0f);
        float weight = 0.0f;
        float spreadWeight = 0.0f;
        foreach (otherBoid; this.boids) {
            auto deltaVal = this.delta(otherBoid.pos, boid.pos);
            float distance = deltaVal.magnitude();
            if (distance < reach) {
                immutable w = 1.0f - distance / reach;
                immutable wdt = w.pow(5.0f);
                meanDelta += deltaVal * wdt;
                meanTrend += otherBoid.vel * wdt;
                weight += wdt;
                // spread
                immutable ws = w.pow(10.0f);
                meanSpread -= deltaVal * ws;
                spreadWeight += ws;
            }
        }
        if (weight != 0.0f) {
            auto vel = 1.0f * boid.vel;
            vel += 0.01f * meanDelta / weight;
            vel += 0.03f * meanTrend / weight;
            vel += 0.02f * meanSpread / spreadWeight;
            boid.vel = vel.normalize();
        }
    }

    Vec2 wrap(Vec2 pos) {
        return Vec2(pos.x.remEuclid(this.size.x), pos.y.remEuclid(this.size.y));
    }
}

Game game;
immutable color = Rgba(232, 232, 232, 255);

// Called once when the game starts.
void ready() {
    lockResolution(800, 600);
    setWindowTitle("Boids");
    //toggleIsFullscreen();
    game = Game.gameInit(0);
    setWindowBackgroundColor(Rgba(43, 43, 56, 255));
}

// Called every frame while the game is running.
// If true is returned, then the game will stop running.
bool update(float dt) {
    game.update(dt);
    if (parin.fps() > 40)
        game.addBoid();
    game.draw(color);
    auto tmp = game.boids.length;
    drawText("FPS: {}".fmt(parin.fps), Vec2(10.0f, 40.0f), DrawOptions(color));
    drawText("Boids: {}".fmt(tmp), Vec2(10.0f, 80.0f), DrawOptions(color));
    drawText("Score: {}".fmt(tmp.pow(2) / 1000.0f), Vec2(10.0f, 120.0f), DrawOptions(color,));
    return false;
}

// Called once when the game ends.
void finish() {
    game.boids.free();
}

// Creates a main function that calls the given functions.
mixin runGame!(ready, update, finish);
